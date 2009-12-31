require File.join(File.dirname(__FILE__), 'test_helper.rb')

class TestCas_2_0_ResponseParser < Test::Unit::TestCase
  def test_parse_valid_ticket
    response = Cas_2_0_ResponseParser.new(VALID_REQUEST)
    assert_equal 'admin', response.user
    assert_equal 2.0, response.protocol
  end
    
  def test_parse_invalid_request
    response = Cas_2_0_ResponseParser.new(INVALID_REQUEST)
    assert_equal 'INVALID_REQUEST', response.failure_code    
    assert_equal 'Ticket or service parameter was missing in the request.', response.failure_message
  end
  
  def test_parse_invalid_ticket
    response = Cas_2_0_ResponseParser.new(INVALID_TICKET)
    assert_equal 'INVALID_TICKET', response.failure_code    
    assert_equal 'Ticket ST-1231242314r72465638160B31E8D1 not recognized.', response.failure_message
  end
    
end