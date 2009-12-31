require File.join(File.dirname(__FILE__), 'test_helper.rb')

class TestClient < Test::Unit::TestCase
  def setup
    @client = Client.new(:cas_server_url => "http://localhost:4567", :service_url => "http://localhost:3000")
  end
  
  def test_config
    assert_equal @client.service_url, "http://localhost:3000"
  end

  def test_config_requires_cas_server_url
    assert_raises(RuntimeError) do
      @client = Client.new({})
    end
  end

  def test_authenticate_ticket
    service_ticket = get_service_ticket
    @client = Client.new(:cas_server_url => "http://localhost:4567", :service_url => "http://localhost:3000")    
    mock_authenticate_ticket(VALID_REQUEST)
    @client.authenticate_ticket(service_ticket)
    assert_equal 'admin', service_ticket.user
  end
  
  def test_validate_expired_ticket
    mock_authenticate_ticket(INVALID_TICKET)
    ticket = 'ST-1231341579r871C5757B79767C21E'
    service_ticket = Ticket.new(ticket, 'http://localhost:3000')
    @client.authenticate_ticket(service_ticket)
    assert_equal 'INVALID_TICKET', service_ticket.failure_code
    #assert_equal "Ticket 'ST-1231341579r871C5757B79767C21E' has already been used up.", ticket.failure_message
  end  

  def test_validate_invalid_ticket
    mock_authenticate_ticket(INVALID_TICKET)
    ticket = 'ST-1231242314r72465638160B31E8D1'
    service_ticket =  Ticket.new(ticket, 'http://localhost:3000')
    @client.authenticate_ticket(service_ticket)
    assert_equal 'INVALID_TICKET', service_ticket.failure_code
    assert_equal "Ticket ST-1231242314r72465638160B31E8D1 not recognized.", service_ticket.failure_message
  end

  def test_authenticate_ticket_with_empty_service_url
    service_ticket = Ticket.new('ticket', nil)
    assert_raises(RuntimeError) do
      @client.authenticate_ticket(service_ticket)
    end
  end

  def test_login_url
    assert_equal 'http://localhost:4567/login?service=http%3A%2F%2Flocalhost%3A3000', @client.login_url
  end
  
  def test_login_url_with_extra_params
    url = @client.login_url(:renew => true)    
    assert_equal true, (url =~ /service\=http%3A%2F%2Flocalhost%3A3000/) > 0
    assert_equal true, (url =~ /renew\=true/) > 0
  end

  def test_logout_url
    assert_equal 'http://localhost:4567/logout?', @client.logout_url
  end
 
  def test_logout_url_with_extra_params
    url = @client.logout_url(:url => 'http://localhost:3000')
    assert_equal true, (url =~ /url\=http%3A%2F%2Flocalhost%3A3000/) > 0
  end 
 
  def test_validate_url
    assert_equal 'http://localhost:4567/proxyValidate', @client.validate_url
  end

end

class TestCommandLineClient < Test::Unit::TestCase
  def setup
    @client = CommandLineClient.new(:cas_server_url => "http://localhost:4567", :service_url => "http://localhost:3000")
  end

  def test_login
    mock_get_service_ticket(@client)
    service_ticket = @client.login('admin', 'admin')
    #assert_equal '', res.body
    #assert_equal '303', res.code
    #assert_equal 0, res['location'] =~ /^http:\/\/localhost:3000\?ticket=ST-/
    assert_equal 32, service_ticket.ticket.size
    assert_equal 37, @client.ticket_granting_ticket.size
  end

  def test_logout
    mock_get_service_ticket(@client)
    service_ticket = @client.login('admin', 'admin')
    assert_equal 37, @client.ticket_granting_ticket.size    
    if MOCK_REQUESTS
      @client.expects(:get).returns(MockResponse.new('<html></html>', '200', :location => 'http://localhost:3000?ticket=ST-1231341579r871C5757B79767C21E'))
    end
    service_ticket = @client.logout
    assert_equal nil, @client.ticket_granting_ticket
  end

  def test_logout_with_follow_url
    mock_get_service_ticket(@client)
    service_ticket = @client.login('admin', 'admin')
    assert_equal 37, @client.ticket_granting_ticket.size    
    if MOCK_REQUESTS
      @client.expects(:get).returns(MockResponse.new('<html></html>', '200', :location => 'http://localhost:3000?ticket=ST-1231341579r871C5757B79767C21E'))
    end
    service_ticket = @client.logout('follow_url')
    assert_equal nil, @client.ticket_granting_ticket
    # TODO check for follow_url
  end
  
  def test_get_service_ticket
    mock_get_service_ticket(@client)
    ticket = @client.login('admin', 'admin')
    assert_equal 0, ticket.ticket =~ /^ST-/
    assert_equal 32, ticket.ticket.size    
  end  
  
  def test_get_proxy_granting_ticket
    mock_get_service_ticket(@client)
    ticket = @client.login('admin', 'admin')
    ticket.pgt_url= "http://localhost/validate_proxy"
    uri = URI.parse("http://localhost:4567/proxyValidate?ticket=#{ticket.ticket}&service=http%3A%2F%2Flocalhost%3A3000&pgtUrl=http%3A%2F%2Flocalhost%3A3000%2FpgtCallback")
    if MOCK_REQUESTS    
      @client.expects(:get).with(uri).returns(MockResponse.new("", '200', :location => 'http://localhost:3000?ticket=ST-1231341579r871C5757B79767C21E'))
    end
    response_body = @client.get_proxy_granting_ticket(ticket)
    assert_equal "", response_body
  end

end

class TestURIHTTP < Test::Unit::TestCase
  def test_merge_query
    uri = URI.parse('http://localhost:4567/login')
    uri.merge_query({:order_by => ['1', '2']})
    assert_equal 'order_by=1&order_by=2', uri.query   
  end
    
  def test_merge_query_with_existing_query
    uri = URI.parse('http://localhost:4567/login?search=ah')
    uri.merge_query({:order_by => ['1', '2']})
    assert_equal 'search=ah&order_by=1&order_by=2', uri.query   
  end
end