require 'dotenv/load'
require 'roda'
require 'sequel'

Sequel.sqlite(ENV['PLAYWHE_DATABASE_URL'], readonly: true)

require_relative './playwhe/models'
require_relative './playwhe/use_cases'
require_relative './playwhe/app'
