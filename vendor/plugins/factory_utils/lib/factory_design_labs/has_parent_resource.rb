module FactoryDesignLabs
  module HasParentResource
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      def has_parent_resource(parent, options = {})
        method_name = "find_parent_#{parent}"
        redirect_url = options[:redirect_url] || "#{parent}s_url"
        param = options[:param] || "#{parent}_id"
        after = options[:after] || ''
        
        before_filter method_name.to_sym
        
        class_eval <<-"end;"
          def #{method_name}
            @#{parent}_id = params[:#{param}]
            redirect_to #{redirect_url} unless @#{parent}_id 
            @#{parent} = #{parent.to_s.classify}.find(@#{parent}_id)
            #{after}
          end  
          private :#{method_name}      
        end;
        
      end
    end
  
  end  
end

ActionController::Base.send :include, FactoryDesignLabs::HasParentResource