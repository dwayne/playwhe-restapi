require 'rack/contrib/jsonp'

require_relative '../lib/playwhe'

use Rack::JSONP
run PlayWhe::App.freeze.app
