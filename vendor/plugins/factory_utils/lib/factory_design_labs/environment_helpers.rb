module FactoryDesignLabs
  module EnvironmentHelpers

    def self.included(base)
      base.class_eval do
        Dir["#{RAILS_ROOT}/config/environments/*"].map {|env| File.basename(env, '.rb')}.each do |env|
          method_name = "is_#{env}?"
          self.class.send(:define_method, method_name) do
            ENV['RAILS_ENV'] == env
          end

          define_method method_name do
            self.class.send(method_name)
          end

          helper_method "is_#{env}?"
        end
      end
    end

  end
end

ActionController::Base.send :include, FactoryDesignLabs::EnvironmentHelpers