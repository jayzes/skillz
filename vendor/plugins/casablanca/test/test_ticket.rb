require File.join(File.dirname(__FILE__), 'test_helper.rb')

class TestTicket < Test::Unit::TestCase
  def setup
    @ticket = Ticket.new('ST-1231242314r72465638160B31E8D1', 'http://localhost:3000')
  end
  
  def test_create_service_ticket
    ticket = Ticket.new('ST-1231242314r72465638160B31E8D1', 'http://localhost:3000')
    assert_equal 'ST-1231242314r72465638160B31E8D1', ticket.to_hash[:ticket]
  end
  
  def test_create_proxy_ticket
    ticket = Ticket.new('PT-1231242314r72465638160B31E8D1', 'http://localhost:3000')
    assert_equal 'PT-1231242314r72465638160B31E8D1', ticket.to_hash[:ticket]
  end

  def test_to_hash
    ticket = Ticket.new('ST-1231242314r72465638160B31E8D1', 'http://localhost:3000')
    assert_equal 'ST-1231242314r72465638160B31E8D1', ticket.to_hash[:ticket]
  end

  def test_from_hash
    props = {:ticket => 'ticket',
                  :service_url => "http://localhost:3000",
                  :user     => 'admin' }
    ticket = Ticket.from_hash(props)
    assert_equal props, ticket.to_hash
  end

  def test_to_request_params
    ticket = Ticket.new('ticket', 'http://localhost:3000')
    expected = {:ticket => 'ticket',
                  :service  => "http://localhost:3000" }
    assert_equal(expected, ticket.to_request_params)
  end

  def test_authenticate_valid_ticket
    @ticket.body = VALID_REQUEST
    @ticket.authenticate
    assert_equal 'admin', @ticket.user
  end

  def test_authenticate_invalid_request_resets_ticket_to_unauthenticated
    @ticket.body = VALID_REQUEST
    @ticket.authenticate
    assert_equal true, @ticket.authenticated?
    @ticket.body = INVALID_REQUEST
    @ticket.authenticate
    assert_equal false, @ticket.authenticated?
  end
    
  def test_authenticate_invalid_request
    @ticket.body = INVALID_REQUEST
    @ticket.authenticate
    assert_equal 'INVALID_REQUEST', @ticket.failure_code    
    assert_equal 'Ticket or service parameter was missing in the request.', @ticket.failure_message
  end
  
  def test_authenticate_invalid_ticket
    @ticket.body = INVALID_TICKET
    @ticket.authenticate
    assert_equal 'INVALID_TICKET', @ticket.failure_code    
    assert_equal 'Ticket ST-1231242314r72465638160B31E8D1 not recognized.', @ticket.failure_message
  end

end