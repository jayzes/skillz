module Casablanca

  class CasResponseParser
    def protocol
      self.class.to_s.gsub(/(Casablanca::Cas_|_ResponseParser)/, '').gsub('_', '.').to_f
    end

    def self.parse(ticket, body)
      raise ResponseError, "Response body is empty" if body.nil? || body.strip == ""
      #return Cas_1_0_Parser.new(body) if ?
      response = Cas_2_0_ResponseParser.new(body)
      ticket.user = response.user      
      unless response.authenticated?
        ticket.failure_code = response.failure_code
        ticket.failure_message = response.failure_message
      end
    end
  end

  class Cas_2_0_ResponseParser < CasResponseParser
    def initialize(xml)
      doc = REXML::Document.new(xml)
      @xml = doc.elements['cas:serviceResponse'].elements[1]
    end

    def user
      strip_text(@xml.elements['cas:user'])
    end

    def authenticated?
      @xml.name == 'authenticationSuccess'
    end

    def failure_code
      @xml.elements['//cas:authenticationFailure'].attributes['code']
    end

    def failure_message
      strip_text(@xml.elements['//cas:authenticationFailure'])
    end

    private

    def strip_text(tag)
      tag.text.strip if tag
    end

  end

end