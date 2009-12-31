config = { :cas_server_url => "http://localhost:4567", :service_url => "http://localhost:3000" }
INFO = %(
=====================================================
CASABLANCA CLIENT CONSOLE (#{Casablanca::VERSION})

Use C for a configured client (#{config.inspect})
Example:

  t = C.login('admin', 'admin')
  C.authenticate_ticket(t)

  C.logout

The configuration can be changed:

  C.cas_server_url = "http://example.com/cas_server"
  C.service_url = "http://example.com/application"

)

C = Casablanca::CommandLineClient.new(config)
C.logger.level = Logger::DEBUG

puts INFO