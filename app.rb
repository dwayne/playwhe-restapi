require 'sinatra'
require 'json'

require './models'

unless ENV['PLAYWHE_DATABASE_URL']
  abort("missing env vars: please set PLAYWHE_DATABASE_URL")
end

DataMapper.setup(:default, "sqlite://#{ENV['PLAYWHE_DATABASE_URL']}")

before do
  content_type :json
end

get '/marks' do
  Mark.all.to_json
end

get %r{^/mark/([1-9]|[1-2][0-9]|3[0-6])$} do |n|
  Mark.get(n).to_json
end

get '/results' do
  Result.all(order: [ :draw.desc ], limit: 3).to_json
end

get %r{^/results/(\d{4})$} do |year|
  # FIXME: Not elegant but the following works for SQLite databases
  results = repository(:default).adapter.select("SELECT * FROM results WHERE strftime('%Y', date) = ? ORDER BY draw DESC", year)
  results.map { |result| Result.new(draw: result.draw, date: result.date, period: result.period, number: result.number)}.to_json
end

get %r{^/results/(\d{4})/(\d{2})$} do |year, month|
  # FIXME: Not elegant but the following works for SQLite databases
  results = repository(:default).adapter.select("SELECT * FROM results WHERE strftime('%Y', date) = ? AND strftime('%m', date) = ? ORDER BY draw DESC", year, month)
  results.map { |result| Result.new(draw: result.draw, date: result.date, period: result.period, number: result.number)}.to_json
end

get %r{^/results/(\d{4})/(\d{2})/(\d{2})$} do |year, month, day|
  # FIXME: Not elegant but the following works for SQLite databases
  results = repository(:default).adapter.select("SELECT * FROM results WHERE strftime('%Y', date) = ? AND strftime('%m', date) = ? AND strftime('%d', date) = ? ORDER BY draw DESC", year, month, day)
  results.map { |result| Result.new(draw: result.draw, date: result.date, period: result.period, number: result.number)}.to_json
end
