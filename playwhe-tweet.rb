# A utility script for automating the posting of Play Whe results to Twitter.

require 'date'
require 'twitter'
require './models'

ENV['PLAYWHE_RESULTS_HASHTAG'] ||= '#playwhe'
ENV['PLAYWHE_WEBSITE_URL']     ||= 'http://playwhesmarter.com/'

unless ENV['PLAYWHE_DATABASE_URL'] and ENV['PLAYWHE_TWEETRC_PATH']
  abort('missing env vars: please set PLAYWHE_DATABASE_URL and PLAYWHE_TWEETRC_PATH')
end

unless ENV['TWITTER_CONSUMER_KEY'] and ENV['TWITTER_CONSUMER_SECRET'] and ENV['TWITTER_OAUTH_TOKEN'] and ENV['TWITTER_OAUTH_SECRET']
  abort('missing env vars: please set your Twitter credentials')
end

DataMapper.setup(:default, "sqlite://#{ENV['PLAYWHE_DATABASE_URL']}")

Twitter.configure do |config|
  config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
  config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['TWITTER_OAUTH_SECRET']
end

if File.exists? ENV['PLAYWHE_TWEETRC_PATH']
  results = []

  File.open(ENV['PLAYWHE_TWEETRC_PATH'], 'r') do |f|
    draw = f.gets.to_i
    results = Result.all(:draw.gt => draw, :order => [ :draw.asc ])
  end
else
  results = [ Result.last ]
end

unless results.empty?
  File.open(ENV['PLAYWHE_TWEETRC_PATH'], 'w') do |f|
    f.puts results[0].draw.to_s
  end

  results.each do |result|
    date = result.date.strftime('%b %-d, %Y')

    time_of_day = {
      1 => 'in the Morning (10:30 AM)',
      2 => 'at Midday (1:00 PM)',
      3 => 'in the Evening (6:30 PM)'
    }[result.period]

    number = result.number
    spirit = Mark.get(number).name

    status = "#{number} (#{spirit}) played on #{date} #{time_of_day}... #{ENV['PLAYWHE_RESULTS_HASHTAG']} ~ #{ENV['PLAYWHE_WEBSITE_URL']}"

    begin
      Twitter.update(status)
    rescue
      puts status
    end
  end
end
