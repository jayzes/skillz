module Casablanca::Rails
   
    class Config

    class << self

      ##
      # Configure the client
      #
      #   Casablanca::Rails::Config.config do |config|
      #     config[:cas_server_url]  = "http://localhost:4567"
      #     # Always require new credentials for authentication
      #     config[:renew]           = true
      #   end
      def config
        config = {}
        yield config
        @cas_server_url = config[:cas_server_url]
        # set logger to rails logger
        Casablanca::Client.logger = ::ActionController::Base.logger        
      end
      
      def cas_server_url
        @cas_server_url
      end
      
    end
  end  
  
  class Filter

    class << self
      
      ##
      # Require a authenticated user to the CAS server otherwise redirect to
      # the CAS server login url.
      # Set session[:cas_user] to the authenticated CAS user if authenticated
      def filter(controller)        
        if authentication_required?(controller)
          return get_credentials(controller)
        elsif controller.params[:ticket]
          return authenticate_ticket(controller)
        else
          return true
        end
      end

      ##
      # The login url of the Cas server. This page has the login form.
      def login_url(controller, params={})
        client = Casablanca::Client.new(:cas_server_url => Config.cas_server_url, :service_url => service_url(controller))        
        client.login_url(params)
      end

      ##
      # The logout url of the Cas server.
      def logout_url(controller, params={})
        client = Casablanca::Client.new(:cas_server_url => Config.cas_server_url, :service_url => service_url(controller))
        client.logout_url(params)
      end
      
      ##
      # Logs out of the Cas server.      
      def logout(controller)
        controller.session[:cas_user] = nil
      end
      
      def logger
        Casablanca::Client.logger
      end
      
      # Has the user already talked to the Cas server?
      def authentication_required?(controller)
        controller.session[:cas_user].nil? && controller.params[:ticket].nil?
      end

      def redirect_to_cas_login(controller)
        controller.send(:redirect_to, login_url(controller))
      end      

      def get_credentials(controller)
        logger.debug "Not authenticated yet. Ticket parameter required"
        redirect_to_cas_login(controller)
        return false
      end        

      def authenticate_ticket(controller)
        client = Casablanca::Client.new(:cas_server_url => Config.cas_server_url, :service_url => service_url(controller))
        ticket = Casablanca::Ticket.new(controller.params[:ticket], client.service_url, controller.session[:cas_renew])
        if client.authenticate_ticket(ticket)
          logger.debug "Ticket authenticated"
          controller.session[:cas_user] = ticket.user
          controller.session[:cas_renew] = nil
          return true
        else          
          logger.debug "Ticket authentication failed: #{ticket.failure_message}"
          logout(controller)
          logger.debug "Renew login credentials"
          redirect_to_cas_login(controller)
          return false
        end
      end        

      private

      def service_url(controller)
        params = controller.params.merge(:only_path => false).dup
        params.delete(:ticket)
        controller.url_for(params)
      end        
      
    end
  end


  class GatewayFilter < Filter

    class << self

      # # Has the user already talked to the Cas server?
      # def authentication_required?(controller)
      #   super(controller)      
      # end    

      def get_credentials(controller)
        if controller.session[:cas_gatewayed]
          logger.debug "Allow user without credentials because gateway is set"
          return true
        end
        return super(controller)
      end
    
      def redirect_to_cas_login(controller)
        controller.session[:cas_gatewayed] = true
        logger.debug "Redirecting to #{login_url(controller, :gateway => true)}"
        controller.send(:redirect_to, login_url(controller, :gateway => true))
      end
      
    end
  end

  ##
  # Always require new credentials for authentication?  
  class RenewFilter < Filter

    class << self

      # Has the user already talked to the Cas server?
      def authentication_required?(controller)
        (controller.session[:cas_user].nil? || controller.session[:cas_renewed].nil?) && controller.params[:ticket].nil?
      end

      def get_credentials(controller)
        logger.debug "Always require credentials for authentication"
        redirect_to_cas_login(controller)
        return false
      end
    
      def redirect_to_cas_login(controller)
        controller.session[:cas_renewed] = true
        logger.debug "Redirecting to #{login_url(controller, :renew => true)}"        
        controller.send(:redirect_to, login_url(controller, :renew => true))
      end
      
    end
  end  
  
end
