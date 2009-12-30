# use to dump db to yml files and load them back into the db
# rake db:bootstrap:dump dumps current db to yml files in db/bootstrap/
# rake db:bootstrap:load loads yml files in db/bootstrap into your empty db.
# Returns an array of column objects for the table associated with this class.


# Returns a hash of column objects for the table associated with table_name.
def columns_hash(table_name)
  columns = ActiveRecord::Base.connection.columns(table_name, "#{table_name} Columns")
  columns.inject({}) { |hash, column| hash[column.name] = column; hash }
end

# run through record hash and cast to value based on column
def cast_data(record, columns_hash)
  record.each do |key, value|
    column = columns_hash[key]
    record[key] = column.type_cast(value)
  end
end

namespace :db do
  namespace :bootstrap do
    
    desc 'Create YAML test fixtures from data in an existing database.  
    Defaults to development database.  Set RAILS_ENV to override.'
    task :dump => :environment do
      native_export = ENV['NATIVE_EXPORT'] == 'true'
      sql  = "SELECT * FROM %s"
      skip_tables = ["schema_info"]
      
      # clear old bootstrap files
      Dir["#{RAILS_ROOT}/db/bootstrap/#{RAILS_ENV}*.yml"].each do |file|
        File.delete(file)
      end
      # make dir if it doesn't exist
      system "mkdir -p #{RAILS_ROOT}/db/bootstrap/#{RAILS_ENV}"
      
      ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
      (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
        i = "000"
        
        # unless native export set grab columns for table
        unless native_export
          columns = columns_hash(table_name)
        end
        
        File.open("#{RAILS_ROOT}/db/bootstrap/#{RAILS_ENV}/#{table_name}.yml", 'w') do |file|
          data = ActiveRecord::Base.connection.select_all(sql % table_name)
          file.write data.inject({}) { |hash, record|
            #unless native export set cast record to ruby values otherwise leave as native db values.
            hash["#{table_name}_#{i.succ!}"] = native_export ? record : cast_data(record, columns)
            hash
          }.to_yaml
        end
      end
    end
    
    desc "Load initial database fixtures (in db/bootstrap/*.yml) into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
    task :load => :environment do
      require 'active_record/fixtures'
      source_bootstrap_env = ENV['SOURCE_BOOTSTRAP_ENV'] || RAILS_ENV 
      
      ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
      ActiveRecord::Base.connection.update "SET FOREIGN_KEY_CHECKS = 0" if ActiveRecord::Base.connection.adapter_name == 'MySQL'
      
      (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/).collect{ |fixture| File.join(RAILS_ROOT, 'db', 'bootstrap', source_bootstrap_env, fixture) } :
                        Dir.glob(File.join(RAILS_ROOT, 'db', 'bootstrap', source_bootstrap_env, '*.{yml,csv}'))).each do |fixture_file|
        Fixtures.create_fixtures("db/bootstrap/#{source_bootstrap_env}", File.basename(fixture_file, '.*'))
      end 
      
      ActiveRecord::Base.connection.update "SET FOREIGN_KEY_CHECKS = 1" if ActiveRecord::Base.connection.adapter_name == 'MySQL'
    end
  end
end
