require 'active_record/fixtures'

module FactoryDesignLabs
  
  module Migration
    
    def append_fixture_data
      directory = File.join(RAILS_ROOT,"db","migrate", "data", self.name.underscore) 
      puts directory
      Dir.glob(File.join(directory,'*.{yml,csv}')).each do |fixture_file|
        puts fixture_file 
        Fixtures.append_fixtures(directory, File.basename(fixture_file, '.*'))
      end
    end
    
  end
  
end

class Fixtures
  def self.append_fixtures(fixtures_directory, table_names, class_names = {})
    table_names = [table_names].flatten.map { |n| n.to_s }
    connection  = block_given? ? yield : ActiveRecord::Base.connection

    table_names_to_fetch = table_names.reject { |table_name| fixture_is_cached?(connection, table_name) }

    unless table_names_to_fetch.empty?
      ActiveRecord::Base.silence do
        connection.disable_referential_integrity do
          fixtures_map = {}

          fixtures = table_names_to_fetch.map do |table_name|
            fixtures_map[table_name] = Fixtures.new(connection, File.split(table_name.to_s).last, class_names[table_name.to_sym], File.join(fixtures_directory, table_name.to_s))
          end

          all_loaded_fixtures.update(fixtures_map)

          connection.transaction(Thread.current['open_transactions'].to_i == 0) do
            # fixtures.reverse.each { |fixture| fixture.delete_existing_fixtures }
            fixtures.each { |fixture| fixture.insert_fixtures }

            # Cap primary key sequences to max(pk).
            if connection.respond_to?(:reset_pk_sequence!)
              table_names.each do |table_name|
                connection.reset_pk_sequence!(table_name)
              end
            end
          end

          cache_fixtures(connection, fixtures_map)
        end
      end
    end
    cached_fixtures(connection, table_names)
  end
end

ActiveRecord::Migration.send :extend, FactoryDesignLabs::Migration