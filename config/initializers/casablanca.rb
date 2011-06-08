require 'casablanca'

Casablanca::Rails::Config.config do |config|
   config[:cas_server_url]  = "http://sso.factorylabs.com"
end