module ActionController
  module Macros
    module AjaxValidation #:nodoc:
      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
      end

      module ClassMethods

        def ajax_validations_for(*args)

          define_method("ajax_validate") do

            fields_to_update = {}
            args.each do |arg|
              if params.include?(arg) && params[arg].is_a?(Hash)
                # creates the object and validates it
                object = arg.to_s.classify.constantize
                object = object.new(params[arg])
                object.valid?
                
                # adds any requested errors into a hash so it can be used in the partial
                error = object.errors.on(params[:field])
                error = error.is_a?(Array) ? error.to_sentence(:skip_last_comma => true) : error
                fields_to_update = {params[:field] => error}
              end
            end

            # renders the ajax validation partial which does all the html tweaking
            render :partial => 'shared/ajax_validation', :locals => {:fields_to_update => fields_to_update}

          end
        
        end

      end

    end
  end
end