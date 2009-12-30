module Rails
  module Generator
    module Commands
      class Create
        
        def create_factory
          template = File.read(source_path('factories.rb'))
          source_to_update  = ERB.new(template, nil, '-').result(binding)
          File.open('test/factories.rb', 'a') { |file| file.write(source_to_update) }
        end
        
      end
      
      class Destroy
        
        def create_factory
          # pass can't undo right now
        end
        
      end
    end
  end
end

class FmodelGenerator < Rails::Generator::NamedBase
  default_options :skip_timestamps => false, :skip_migration => false, :generate_fixture => false

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_name, "#{class_name}Test"

      # Model, test, and fixture directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('test/unit', class_path)
      m.directory File.join('test/fixtures', class_path)

      # Model class, unit test, and fixtures.
      m.template 'model.rb',      File.join('app/models', class_path, "#{file_name}.rb")
      m.template 'unit_test.rb',  File.join('test/unit', class_path, "#{file_name}_test.rb")

      if options[:generate_fixture] 
       	m.template 'fixtures.yml',  File.join('test/fixtures', "#{table_name}.yml")
      end

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end
      
      m.create_factory
      
    end
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name} ModelName [field:type, field:type]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-timestamps",
             "Don't add timestamps to the migration file for this model") { |v| options[:skip_timestamps] = v }
      opt.on("--skip-migration", 
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
      opt.on("--generate-fixture",
             "Generate a fixture file for this model") { |v| options[:generate_fixture] = v}
    end
end
