module Rails
  module Generator
    module Commands
      class Create
        
        def route_namespaced_resource(resources, namespaces)
          if namespaces && namespaces.length > 1
            logger.warning "multiple nested namespaced routes not supported in route generation please create manually"
            return
          end
          resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
          namespaced_sentinel = !namespaces.empty? ? "map.namespace :#{namespaces.first} do |#{namespaces.first}|" : ''
          standard_sentinel = 'ActionController::Routing::Routes.draw do |map|'
          sentinel = namespaces.empty? ? standard_sentinel : namespaced_sentinel

          logger.route "map.resources #{resource_list}"
          unless options[:pretend]
            path = destination_path('config/routes.rb')
            content = File.read(path) 
            unless !namespaced_sentinel.blank? && /(#{Regexp.escape(namespaced_sentinel)})/mi =~ content
              gsub_file 'config/routes.rb', /(#{Regexp.escape(standard_sentinel)})/mi do |match|
                "#{match}\n  #{namespaced_sentinel}\n"
              end
            end
            logger.route sentinel
            gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
            # logger.route match
              "#{match}\n  map.resources #{resource_list}\n"
            end
          end
        end
        
      end
      
      class Destroy
        
        def route_namespaced_resource(resources, namespaces)
          resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
          look_for = "\n  map.resources #{resource_list}\n"
          logger.route "map.resources #{resource_list}"
          gsub_file 'config/routes.rb', /(#{look_for})/mi, ''
        end
        
      end
    end
  end
end

class FscaffoldGenerator < Rails::Generator::NamedBase
  default_options :skip_timestamps => false, :skip_migration => false, :force_plural => false, :generate_helper => false, :xml => false 

  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_singular_name,
                :controller_plural_name,
                :default_attribute_name,
                :default_attribute_value,
                :controller_namespaces,
                :singular_route_path,
                :plural_route_path,
                :url_for_args
  alias_method  :controller_file_name,  :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    super

    if @name == @name.pluralize && !options[:force_plural]
      logger.warning "Plural version of the model detected, using singularized version.  Override with --force-plural."
      @name = @name.singularize
    end

    @controller_name = @name.pluralize

    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_underscore_name, @controller_plural_name = inflect_names(base_name)
    @controller_singular_name=base_name.singularize 
    
    logger.route @controller_file_path
    
    if @controller_class_nesting.empty?
      @controller_namespaces = []
      @singular_route_path = singular_name
      @plural_route_path = plural_name
      @url_for_args = "@#{singular_name}"
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_namespaces = controller_class_nesting.split('::').inject([]){|list, n| list << n.underscore }
      @singular_route_path = "#{@controller_namespaces.join('_')}_#{singular_name}"
      @plural_route_path = "#{@controller_namespaces.join('_')}_#{plural_name}"
      @url_for_args = "[:#{controller_namespaces.join', :'}, @#{singular_name}]"
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
    
    
    if attributes && !attributes.empty? 
      @default_attribute_name = attributes.first.name
      @default_attribute_value = attributes.first.default
      @default_attribute_value = @default_attribute_value.is_a?(String) ? "'#{@default_attribute_value}'" : @default_attribute_value
    else
       @default_attribute_name = 'updated_at'
       @default_attribute_value = 'Time.now'
    end
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions("#{controller_class_name}Controller", "#{controller_class_name}Helper")
      m.class_collisions(class_name)

      # Controller, helper, views, test and stylesheets directories.
      # m.directory(File.join('app/models', class_path))
      m.directory(File.join('app/controllers', controller_class_path))
      m.directory(File.join('app/helpers', controller_class_path))
      m.directory(File.join('app/views', controller_class_path, controller_file_name))
      m.directory(File.join('app/views/layouts', controller_class_path))
      m.directory(File.join('test/functional', controller_class_path))
      m.directory(File.join('test/unit', class_path))
      m.directory(File.join('public/stylesheets', class_path))

      for action in scaffold_views
        m.template(
          "view_#{action}.html.erb",
          File.join('app/views', controller_class_path, controller_file_name, "#{action}.html.erb")
        )
      end

      m.template(
        'controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
      )

      m.template('functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
      if options[:generate_helpers]
        m.template('helper.rb',          File.join('app/helpers',     controller_class_path, "#{controller_file_name}_helper.rb"))
      end
      m.route_namespaced_resource controller_file_name, controller_namespaces

      m.dependency 'fmodel', [model_name] + @args, :collision => :skip
    end
  end

  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} scaffold ModelName [field:type, field:type]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-timestamps",
             "Don't add timestamps to the migration file for this model") { |v| options[:skip_timestamps] = v }
      opt.on("--skip-migration",
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }      
      opt.on("--xml",
            "create format.xml responses in respond_to blocks") { |v| options[:xml] = v } 
      opt.on("--generate-helper",
            "Generate a helper file") { |v| options[:generate_helper] = v }    
    end

    def scaffold_views
      %w[ index show new edit ]
    end

    def model_name
      class_name.demodulize
    end
end
