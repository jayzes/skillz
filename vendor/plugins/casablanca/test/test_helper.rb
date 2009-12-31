require 'test/unit'
require 'rubygems'
require 'mocha'
# require 'logger'
require(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'casablanca.rb')))
require(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'casablanca', 'client.rb')))
require(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'casablanca', 'rails', 'filter.rb')))
require(File.expand_path(File.join(File.dirname(__FILE__), 'mocks.rb')))
require(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'casablanca', 'rails', 'cas_proxy_callback_controller.rb')))

# set to false if you're integration testing against a real server
MOCK_REQUESTS = true unless defined? MOCK_REQUESTS
LOGGER_LEVEL = Logger::WARN unless defined? LOGGER_LEVEL

class Test::Unit::TestCase
  include Casablanca
  
  def mock_authenticate_ticket(body)
    if MOCK_REQUESTS
      Client.any_instance.expects(:get).returns(MockResponse.new(body, '200', :location => 'http://localhost:3000?ticket=ST-1231341579r871C5757B79767C21E'))
    end
  end
  
  def mock_get_service_ticket(client=Client.any_instance)
    if MOCK_REQUESTS
      client.expects(:post).returns(MockResponse.new('', '303', :location => 'http://localhost:3000?ticket=ST-1231341579r871C5757B79767C21E', :'set-cookie' => 'tgt=TGC-1232569033r763536CC6753E6F357'))
    end
  end

  def get_service_ticket
    cli = CommandLineClient.new(:cas_server_url => "http://localhost:4567", :service_url => "http://localhost:3000")
    if MOCK_REQUESTS
      cli.expects(:post).returns(MockResponse.new('', '303', {:location => 'http://localhost:3000?ticket=ST-1231341579r871C5757B79767C21E', :'set-cookie' => 'tgt=TGC-1232569033r763536CC6753E6F357'}))
    end
    cli.login('admin', 'admin')
  end 
end

unless defined? VALID_REQUEST
VALID_REQUEST = %(
<cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
  <cas:authenticationSuccess>
    <cas:user>admin</cas:user>        
  </cas:authenticationSuccess>
</cas:serviceResponse>
)

INVALID_REQUEST = %(
  <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
    <cas:authenticationFailure code="INVALID_REQUEST">
    Ticket or service parameter was missing in the request.
    </cas:authenticationFailure>
  </cas:serviceResponse>
)

INVALID_TICKET = %(
<cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
  <cas:authenticationFailure code="INVALID_TICKET">
  Ticket ST-1231242314r72465638160B31E8D1 not recognized.
  </cas:authenticationFailure>
</cas:serviceResponse>
)
end