  require File.join(File.dirname(__FILE__), 'test_helper.rb')

class TestRailsConfig < Test::Unit::TestCase  
  
  def setup
    @controller = Controller.new    
    @controller.params = {}
  end
    
  def test_config
    Rails::Config.config do |config|
       config[:cas_server_url]  = "http://example.com/cas_server"
    end
    assert_equal 'http://example.com/cas_server/login?service=http%3A%2F%2Flocalhost%3A3000', Rails::Filter.login_url(@controller)
  end
  
end

class TestRailsFilter < Test::Unit::TestCase
  include Casablanca::Rails
  def setup
    Config.config do |config|
       config[:cas_server_url]  = "http://localhost:4567"
    end
    @controller = Controller.new    
    @controller.params = {}
  end
  
  def test_login_url
    assert_equal 'http://localhost:4567/login?service=http%3A%2F%2Flocalhost%3A3000', Filter.login_url(@controller)
  end

  def test_login_url_with_params
    url = Filter.login_url(@controller, :renew => true)
    assert_equal true, (url =~ /service\=http%3A%2F%2Flocalhost%3A3000/) > 0
    assert_equal true, (url =~ /renew\=true/) > 0
  end

  def test_logout_url
    assert_equal 'http://localhost:4567/logout?', Filter.logout_url(@controller)
  end  
  
  def test_logout
    @controller.session = { :cas_user => 'admin' }
    Filter.logout(@controller)
    assert_equal({:cas_user=>nil }, @controller.session)
  end

  def test_filter_invalid_attempt
    service_ticket = get_service_ticket    
    params = {:ticket => 'service_ticket.ticket'}
    mock_authenticate_ticket(INVALID_REQUEST)
    @controller.params = params 
    assert_equal false, Filter.filter(@controller)
  end

  def test_filter_authenticated_with_valid_ticket_from_request
    service_ticket = get_service_ticket    
    params = {:ticket => service_ticket.ticket}
    mock_authenticate_ticket(VALID_REQUEST)
    @controller.params = params
    assert_equal true, Filter.filter(@controller)
    assert_equal 'admin', @controller.session[:cas_user]
  end

  def test_filter_already_authenticated_with_valid_ticket_from_session
    service_ticket = get_service_ticket    
    @controller.session = {:cas_user => 'admin'}
    assert_equal true, Filter.filter(@controller)
    assert_equal 'admin', @controller.session[:cas_user]    
  end

  def test_filter_not_authenticated
    assert_equal false, Filter.filter(@controller)
  end

  def test_filter_not_authenticated
    assert_equal false, Filter.filter(@controller)
  end

end

class TestRailsGatewayFilter < TestRailsFilter
  def setup
    Config.config do |config|
       config[:cas_server_url]  = "http://localhost:4567"
    end
    @controller = Controller.new    
    @controller.params = {}
  end  

  def test_filter_not_authenticated_sets_cas_gatewayed
    # service_ticket = get_service_ticket
    #mock_authenticate_ticket(VALID_REQUEST)
    assert_equal false, GatewayFilter.filter(@controller)
    assert_equal true, @controller.session[:cas_gatewayed]
  end

  def test_filter_not_authenticated_already_tried
    # service_ticket = get_service_ticket
    @controller.session = {:cas_gatewayed => true}
    #mock_authenticate_ticket(VALID_REQUEST)
    assert_equal true, GatewayFilter.filter(@controller)
    assert_equal nil, @controller.session[:cas_user]    
  end

end

class TestRailsRenewFilter < TestRailsFilter
  def setup
    Config.config do |config|
       config[:cas_server_url]  = "http://localhost:4567"
    end
    @controller = Controller.new    
    @controller.params = {}
  end

  def test_filter_already_authenticated_on_cas_server_but_renew_required
    Config.config do |config|
       config[:cas_server_url]  = "http://localhost:4567"
    end    
    service_ticket = get_service_ticket
    @controller.session = {:cas_user => 'admin'}       
    assert_equal false, RenewFilter.filter(@controller)
  end

  def test_filter_already_renewed_with_valid_ticket_from_session_should_not_renew
    Config.config do |config|
       config[:cas_server_url]  = "http://localhost:4567"
    end    
    service_ticket = get_service_ticket    
    @controller.session = {:cas_user => 'admin', :cas_renewed => true}
    assert_equal true, RenewFilter.filter(@controller)
    assert_equal 'admin', @controller.session[:cas_user]    
  end

end