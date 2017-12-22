# A utility script for automating the posting of Play Whe results to Twitter.

require 'date'
require 'sequel'
require 'twitter'

ENV['PLAYWHE_RESULTS_HASHTAG'] ||= '#playwhe'
ENV['PLAYWHE_WEBSITE_URL']     ||= 'http://www.playwhesmarter.com/'

unless ENV['PLAYWHE_DATABASE_URL'] and ENV['PLAYWHE_TWEETRC_PATH']
  abort('missing env vars: please set PLAYWHE_DATABASE_URL and PLAYWHE_TWEETRC_PATH')
end

unless ENV['TWITTER_CONSUMER_KEY'] and ENV['TWITTER_CONSUMER_SECRET'] and ENV['TWITTER_ACCESS_TOKEN'] and ENV['TWITTER_ACCESS_SECRET']
  abort('missing env vars: please set your Twitter credentials')
end

Sequel.sqlite(ENV['PLAYWHE_DATABASE_URL'], readonly: true)

require_relative './lib/playwhe/models'

client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
end

if File.exists? ENV['PLAYWHE_TWEETRC_PATH']
  results = []

  File.open(ENV['PLAYWHE_TWEETRC_PATH'], 'r') do |f|
    date, period = f.gets.chomp.split(',')
    results = PlayWhe::Models::Result
      .after(date, period)
      .limit(ENV.fetch('PLAYWHE_TWEETRC_LIMIT', 4))
      .all
  end
else
  results = [ PlayWhe::Models::Result.first ]
end

unless results.empty?
  File.open(ENV['PLAYWHE_TWEETRC_PATH'], 'w') do |f|
    result = results.last
    f.puts "#{result.date},#{result.period}"
  end

  results.each do |result|
    date = Date.parse(result.date).strftime('%b %-d, %Y')

    time_of_day = {
      'EM' => 'in the Morning (10:30 AM)',
      'AM' => 'at Midday (1:00 PM)',
      'AN' => 'in the Afternoon (4:00 PM)',
      'PM' => 'in the Evening (6:30 PM)'
    }.fetch(result.period)

    number = result.number
    spirit = PlayWhe::Models::Mark[number].name

    status = "#{number} (#{spirit}) played on #{date} #{time_of_day}... #{ENV['PLAYWHE_RESULTS_HASHTAG']} ~ #{ENV['PLAYWHE_WEBSITE_URL']}"

    begin
      client.update(status)
    rescue
      puts status
    end
  end
end
