# if ENV['RAILS_GEM_VERSION'].to_ < 2
#   namespace :db do
#     namespace :create do
#       desc 'Create all the local databases defined in config/database.yml'
#       task :all => :environment do
#         ActiveRecord::Base.configurations.each_value do |config|
#           # Skip entries that don't have a database key, such as the first entry here:
#           #
#           #  defaults: &defaults 
#           #    adapter: mysql 
#           #    username: root
#           #    password: 
#           #    host: localhost
#           #  
#           #  development: 
#           #    database: blog_development
#           #    <<: *defaults
#           next unless config['database']
#           # Only connect to local databases
#           if %w( 127.0.0.1 localhost ).include?(config['host']) || config['host'].blank?
#             create_database(config)
#           else
#             p "This task only creates local databases. #{config['database']} is on a remote host."
#           end
#         end
#       end
#     end
# 
#     desc 'Create the database defined in config/database.yml for the current RAILS_ENV'
#     task :create => :environment do
#       create_database(ActiveRecord::Base.configurations[RAILS_ENV])
#     end
# 
#     def create_database(config)
#       begin
#         ActiveRecord::Base.establish_connection(config)
#         ActiveRecord::Base.connection
#       rescue
#         case config['adapter']
#         when 'mysql'
#           @charset   = ENV['CHARSET']   || 'utf8'
#           @collation = ENV['COLLATION'] || 'utf8_general_ci'
#           begin
#             ActiveRecord::Base.establish_connection(config.merge({'database' => nil}))
#             ActiveRecord::Base.connection.create_database(config['database'], {:charset => @charset, :collation => @collation})
#             ActiveRecord::Base.establish_connection(config)
#           rescue
#             $stderr.puts "Couldn't create database for #{config.inspect}"
#           end
#         when 'postgresql'
#           `createdb "#{config['database']}" -E utf8`
#         when 'sqlite'
#           `sqlite "#{config['database']}"`
#         when 'sqlite3'
#           `sqlite3 "#{config['database']}"`
#         end
#       else
#         p "#{config['database']} already exists"
#       end
#     end
# 
#     namespace :drop do
#       desc 'Drops all the local databases defined in config/database.yml'
#       task :all => :environment do
#         ActiveRecord::Base.configurations.each_value do |config|
#           # Skip entries that don't have a database key
#           next unless config['database']
#           # Only connect to local databases
#           if config['host'] == 'localhost' || config['host'].blank?
#             drop_database(config)
#           else
#             p "This task only drops local databases. #{config['database']} is on a remote host."
#           end
#         end
#       end
#     end
# 
#     desc 'Drops the database for the current RAILS_ENV'
#     task :drop => :environment do
#       drop_database(ActiveRecord::Base.configurations[RAILS_ENV || 'development'])
#     end
# 
# 
#     namespace :migrate do
#       desc  'Rollbacks the database one migration and re migrate up. If you want to rollback more than one step, define STEP=x'
#       task :redo => [ 'db:rollback', 'db:migrate' ]
# 
#       desc 'Resets your database using your migrations for the current environment'
#       task :reset => ["db:drop", "db:create", "db:migrate"]
#     end
# 
#     desc 'Rolls the schema back to the previous version. Specify the number of steps with STEP=n'
#     task :rollback => :environment do
#       step = ENV['STEP'] ? ENV['STEP'].to_i : 1
#       version = ActiveRecord::Migrator.current_version - step
#       ActiveRecord::Migrator.migrate('db/migrate/', version)
#     end
# 
#     desc 'Drops and recreates the database from db/schema.rb for the current environment.'
#     task :reset => ['db:drop', 'db:create', 'db:schema:load']
# 
#   end
# 
#   def drop_database(config)
#     case config['adapter']
#     when 'mysql'
#       ActiveRecord::Base.connection.drop_database config['database']
#     when /^sqlite/
#       FileUtils.rm_f(File.join(RAILS_ROOT, config['database']))
#     when 'postgresql'
#       `dropdb "#{config['database']}"`
#     end
#   end
# end
# 
