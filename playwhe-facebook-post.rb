# A utility script for automating the posting of Play Whe results to the
# Play Whe Smarter Facebook page.

require 'date'
require 'koala'
require 'sequel'

ENV['PLAYWHE_WEBSITE_URL'] ||= 'http://www.playwhesmarter.com/'

unless ENV['PLAYWHE_DATABASE_URL'] and ENV['PLAYWHE_FACEBOOK_POSTRC_PATH']
  abort('missing env vars: please set PLAYWHE_DATABASE_URL and PLAYWHE_FACEBOOK_POSTRC_PATH')
end

unless ENV['FACEBOOK_PAGE_ACCESS_TOKEN']
  abort('missing env vars: please set your Facebook page access token')
end

Sequel.sqlite(ENV['PLAYWHE_DATABASE_URL'], readonly: true)

require_relative './lib/playwhe/models'

if File.exists? ENV['PLAYWHE_FACEBOOK_POSTRC_PATH']
  results = []

  File.open(ENV['PLAYWHE_FACEBOOK_POSTRC_PATH'], 'r') do |f|
    date, period = f.gets.chomp.split(',')
    results = PlayWhe::Models::Result
      .after(date, period)
      .limit(ENV.fetch('PLAYWHE_FACEBOOK_POSTRC_LIMIT', 4))
      .all
  end
else
  results = [ PlayWhe::Models::Result.first ]
end

unless results.empty?
  File.open(ENV['PLAYWHE_FACEBOOK_POSTRC_PATH'], 'w') do |f|
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

    status = "#{number} (#{spirit}) played on #{date} #{time_of_day}."

    begin
      page = Koala::Facebook::API.new(ENV['FACEBOOK_PAGE_ACCESS_TOKEN'])
      page.put_wall_post(status, {
        link: ENV['PLAYWHE_WEBSITE_URL']
      })
    rescue
      puts status
    end
  end
end
