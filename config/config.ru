require 'rack/cors'

require_relative '../lib/playwhe'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :options]
  end
end

run PlayWhe::App.freeze.app
