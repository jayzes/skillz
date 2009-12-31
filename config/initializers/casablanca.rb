require 'casablanca'

Casablanca::Rails::Config.config do |config|
   config[:cas_server_url]  = "http://localhost:4567"
end