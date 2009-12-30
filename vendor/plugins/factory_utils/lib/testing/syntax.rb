module Testing
  module Syntax
      module ActiveRecord #:nodoc:
 
        def self.included(base) # :nodoc:
          base.extend ClassMethods
        end
 
        module ClassMethods #:nodoc:
 
          def factory(*args, &block)
            if args.empty? || args[0].is_a?(Hash)
              factory_name = self.name.underscore.to_sym
              options = args[0] || {}
            else
              factory_name = args.shift
              options = args[0] || {}
              options[:class] = self
            end
            
            Factory.define(factory_name, options, &block)
          end
 
        end
 
      end
  end
end