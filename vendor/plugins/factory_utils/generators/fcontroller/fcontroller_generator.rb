class FcontrollerGenerator < Rails::Generator::NamedBase
  default_options :generate_helper => false 
  
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions "#{class_name}Controller", "#{class_name}ControllerTest", "#{class_name}Helper"

      # Controller, helper, views, and test directories.
      m.directory File.join('app/controllers', class_path)
      m.directory File.join('app/helpers', class_path)
      m.directory File.join('app/views', class_path, file_name)
      m.directory File.join('test/functional', class_path)

      # Controller class, functional test, and helper class.
      m.template 'controller.rb',
                  File.join('app/controllers',
                            class_path,
                            "#{file_name}_controller.rb")

      m.template 'functional_test.rb',
                  File.join('test/functional',
                            class_path,
                            "#{file_name}_controller_test.rb")
      if options[:generate_helpers]
        m.template 'helper.rb',
                    File.join('app/helpers',
                              class_path,
                              "#{file_name}_helper.rb")   
      end 

      # View template for each action
     ( actions || ['index'] ).each do |action|
        path = File.join('app/views', class_path, file_name, "#{action}.html.erb")
        m.template 'view.html.erb', path,
          :assigns => { :action => action, :path => path }
      end
    end
  end
  
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--generate-helper",
           "Generate a helper") { |v| options[:generate_helper] = v }
  end
end
