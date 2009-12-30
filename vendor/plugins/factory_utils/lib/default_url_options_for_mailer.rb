module UrlWriterRetardaseInhibitor
  module ActionMailer
    Host = 'localhost'
    Port = '3000'
    Protocol = 'http'
    def self.included(am)
      am.send(:include, ::ActionController::UrlWriter)
      ::ActionController::UrlWriter.module_eval do
        default_url_options[:host] = UrlWriterRetardaseInhibitor::ActionMailer::Host
        default_url_options[:port] = UrlWriterRetardaseInhibitor::ActionMailer::Port
        default_url_options[:protocol] = UrlWriterRetardaseInhibitor::ActionMailer::Protocol
      end
    end
  end
end