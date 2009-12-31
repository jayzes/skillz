require 'uri'
require 'cgi'
require 'net/https'
require 'rexml/document'
require 'logger'

module Casablanca
  
  class Client
    attr_accessor :cas_server_url, :service_url

    def initialize(config)
      raise ":cas_server_url is required" unless config[:cas_server_url]
      @cas_server_url = config[:cas_server_url]
      @service_url = config[:service_url]
    end

    ##
    # Validates a Ticket to the validation url of the CAS Server
    # and checks if the ticket is authenticated
    def authenticate_ticket(ticket)
      request_validation(ticket)
      ticket.authenticate
    end

    ##
    # The login url of the Cas server. This page has the login form.
    def login_url(params={})
      uri = URI.parse("#{@cas_server_url}/login")
      query = {:service => @service_url}
      # TODO Check that only one of these can be set
      query[:renew] = 'true' if params[:renew]
      query[:gateway] = 'true' if params[:gateway]      
      uri.merge_query(query)
      uri.to_s
    end

    ##
    # The logout url of the Cas server
    def logout_url(params={})
      uri = URI.parse("#{@cas_server_url}/logout")
      query = {}
      query[:url] = params[:url] if params[:url]
      uri.merge_query(query)
      uri.to_s
    end

    ##
    # The proxy validation url of the Cas server.
    def validate_url
      "#{@cas_server_url}/proxyValidate"
    end

    def logger
      self.class.logger
    end

    def logger=logger
      self.class.logger = logger
    end

    def self.logger=logger
      @logger = logger
    end

    def self.logger
      unless @logger
        @logger = ::Logger.new($stderr)
        @logger.level = Logger::WARN
      end
      @logger
    end
    
    protected

    def request_validation(ticket)
      raise "ticket.service_url cannot be empty" if ticket.service_url.nil? || ticket.service_url.strip == ""      
      uri = URI.parse(validate_url)
      uri.merge_query(ticket.to_request_params)
      puts uri.to_s
      response = get(uri)
      unless response.kind_of?(Net::HTTPSuccess)
        raise ResponseError, "#{response.code}, #{response.body}"
      end
      ticket.body = response.body
    end
    
    private
    
    def get(uri)
      https(uri) do |h|
        h.get("#{uri.path}?#{uri.query}", headers)
      end
    end 

    def https(uri)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = (uri.scheme == 'https')
      begin
        response = https.start do |h|
          yield(h)
        end
      rescue Errno::ECONNREFUSED => error
        raise CasServerException
      end
      logger.debug(response_log(response))
      response     
    end
    
    def headers
      {'cookie' => @ticket_granting_ticket || ''}
    end

    def response_log(response)
      msg = "################\n"
      msg << "  #{@cas_server_url} #{response.inspect}:\n"
      msg << "  body: #{response.body}\n"
      msg << "  headers:\n"
      response.each_key do |k|
        msg << "    - #{k}: #{response[k]}\n"
      end
      msg
    end

  end

  class CommandLineClient < Client
    attr_reader :ticket_granting_ticket
    ##
    # Logs in to the CAS server and returns the response
    def login(username, password)
      response = get_ticket_granting_ticket(username, password)
      get_service_ticket(response)
    end

    def logout(follow_url=nil)
      @ticket_granting_ticket = nil
      uri = URI.parse(logout_url)
      uri.merge_query(:url => follow_url) if follow_url
      get(uri)
    end
    
    def get_proxy_granting_ticket(ticket)
      ticket.pgt_url = 'http://localhost:3000/pgtCallback'
      request_validation(ticket)
    end    

    private

    def post(uri, form_data)
      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data(form_data, ';')
      https(uri) do |h|
        h.request(req)
      end
    end
    
    def get_service_ticket(response)
      if (location = response['location'])
        query = {}
        URI.parse(location).query.collect{|q| k,v = q.split('='); query[k] = v }
        Ticket.new(query['ticket'], @service_url)
      end
    end

    def get_ticket_granting_ticket(username, password)
      @ticket_granting_ticket = nil
      response = post(URI.parse(login_url), {:username => username, :password => password, :service => service_url})      
      @ticket_granting_ticket = (response['set-cookie'] || '').split(/;/)[0] # tgt=TGC-1232569033r763536CC6753E6F357
      response
    end
  end

  class Ticket
    attr_accessor :user, :failure_code, :failure_message, :pgt_url
    attr_reader :service_url, :ticket
    attr_writer :body
    def initialize(ticket, service_url, renew = false)      
      @service_url = service_url
      @ticket  = ticket
      @renew = renew
    end

    ##
    # Create a Ticket from a Hash. Useful for unserializing
    def self.from_hash(hash)
      ticket = Ticket.new(hash[:ticket], hash[:service_url])
      ticket.user = hash[:user]
      ticket
    end

    ##
    # Convert a Ticket to a Hash. Useful for serializing    
    def to_hash
      props = {}
      props[:user] = @user if authenticated?
      props[:service_url] = @service_url
      props[:ticket] = @ticket
      props
    end

    ##
    # Convert the ticket to a Hash for a request
    def to_request_params
      params = {}
      params[:service] = @service_url
      params[:ticket] = @ticket if @ticket
      params[:renew] = 'true' if @renew
      params[:pgtUrl] = @pgt_url if @pgt_url
      params
    end
    
    def authenticated?
      !!@user
    end

    def authenticate
      response = CasResponseParser.parse(self, @body)
      authenticated?
    end
  end

  class ResponseError < Exception
  end

  class CasServerException < Exception
  end
  
  class UnknownTicketType <  Exception
  end
end

##
# Monkey patches for URI::HTTP
class URI::HTTP
  
  ##
  # Adds the hash to query
  def merge_query(hash)
    q = query ? query + '&' : ''
    self.query = "#{q}#{hash_to_uri_array(hash)}"
  end
  
  private
  
  def hash_to_uri_array(hash)
    hash.collect do |name, value|
      if value.kind_of? Array
        value.map {|v| stringify_param(name, v) }
      else
        stringify_param(name, value)
      end
    end.join('&')
  end

  def stringify_param(name, value)
    "#{CGI::escape(name.to_s)}=#{CGI::escape(value.to_s)}"
  end  
end