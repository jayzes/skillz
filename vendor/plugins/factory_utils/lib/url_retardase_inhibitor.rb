# taken from pivotal labs to help with having host for url writer in ActionMailer
module UrlWriterRetardaseInhibitor
  module ActionController
    def self.included(ac)
      ac.send(:include, InstanceMethods)
      ac.around_filter :inhibit_retardase
    end

    module InstanceMethods
      def inhibit_retardase
        begin
          request = self.request
          ::ActionController::UrlWriter.module_eval do
            @old_default_url_options = default_url_options.clone
            default_url_options[:protocol] = request.protocol
            default_url_options[:host] = request.host
            if request.port == request.standard_port
              default_url_options.delete(:port)
            else
              default_url_options[:port] = request.port
            end
          end
          yield
        ensure
          ::ActionController::UrlWriter.module_eval do
            default_url_options[:host] = @old_default_url_options[:host]
            default_url_options[:port] = @old_default_url_options[:port]
            default_url_options[:protocol] = @old_default_url_options[:protocol]
          end
        end
      end
    end
  end
end

ActionController::Base.send(:include, UrlWriterRetardaseInhibitor::ActionController)

