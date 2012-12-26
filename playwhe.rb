require 'sinatra/base'
require 'rack/contrib/jsonp'
require 'json'

require './helpers'
require './models'

unless ENV['PLAYWHE_DATABASE_URL']
  abort("missing env vars: please set PLAYWHE_DATABASE_URL")
end

DataMapper.setup(:default, "sqlite://#{ENV['PLAYWHE_DATABASE_URL']}")

class PlayWhe < Sinatra::Base
  include PlayWheHelper

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
    results.to_json
  end

  not_found do
    {message: 'Not found'}.to_json
  end

  error do
    {message: env['sinatra.error'].message}.to_json
  end

  use Rack::JSONP

  # start the server if executed directly
  run! if app_file == $0
end
