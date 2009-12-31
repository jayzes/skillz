
class MockResponse < Net::HTTPResponse
  attr_accessor :body, :code
  def initialize(body, code=200, header={})
      @body, @code, @header = body, code, header
  end

  def []= key, value
      @header[key.to_sym] = value
  end

  def [] key
      @header[key.to_sym]
  end
  
  def kind_of?(klass)
    if klass == Net::HTTPSuccess
      code.to_i == 200
    end
  end
end

module ActionController
  class Base
    def self.logger
      @logger = ::Logger.new($stderr)
      @logger.level = LOGGER_LEVEL
      @logger
    end
  end
end

class Controller < ActionController::Base
  attr_accessor :params, :session
  def initialize
    @session = {}
  end
  
  def request
    Request.new
  end
  
  def url_for(url)
    if url.is_a? Hash
      return "http://localhost:3000" if url[:only_path] == false
    end
    url
  end
  
  def redirect_to(url)
  end
  
  private
  
  def reset_session
    @session = {}
  end
end

class Request
  def headers
    {}
  end
  def post?
  end
end