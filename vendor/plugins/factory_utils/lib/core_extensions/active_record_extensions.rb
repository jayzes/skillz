module CoreExtensions
  module ActiveRecordExtensions
    
    module InstanceMethods
      
      def has_attribute_values?(hash = {})
        hash.each do |attr,value|
          return false unless self.attributes[attr] == value
        end
        return true
      end
      
      def <=>(other)
         if self.id == other.id then 
           0
         else
           self.id < other.id ? -1 : 1
         end
       end
      
    end
    
    module ClassMethods
      
      def concerns(*values)
        values.each { |c| require_dependency "#{name.underscore}/#{c}" }
      end
      
      def has_checksum(*attrs)
        cattr_accessor :attributes_for_checksum
        self.attributes_for_checksum = attrs

        def self.calculate_checksum(name, value, row)
          row.symbolize_keys!
          Digest::MD5.hexdigest attributes_for_checksum.map { |attr| row[attr] }.join('|')
        end

        class_eval do
          def calculate_checksum
            self.class.calculate_checksum(nil, nil, self.attributes)
          end
        end
      end

      def chunked_each(options = {}, limit = 50)
        rows = find(:all, {:conditions => ["`#{table_name}`.id > ?", 0], :limit => limit}.merge(options))
        while rows.any?
          logger.info "Grabbing next chunk of #{limit} starting at #{rows.last.id}"
          transaction do
            rows.each { |record| yield record }
          end
          rows = find(:all, {:conditions => ["`#{table_name}`.id > ?", rows.last.id], :limit => limit}.merge(options))
        end
        self
      end

      def validates_presence_of_boolean(*attributes)
        attributes.each do |attribute|
          validates_inclusion_of attribute, :in => [true, false], :message => :blank
        end
      end
      
      def resave_all(options={}, chunk_size=500)
        ThinkingSphinx.define_indexes = false
        ThinkingSphinx.deltas_enabled = false

        total = self.count
        current_count = 1
        puts "Resaving #{total} #{self.name} records..."
        chunked_each(options, chunk_size) do |record|
          yield record if block_given?
          record.save
          puts "Saved ID##{record.id} (#{current_count} of #{total})"
          current_count += 1
        end
        
        ThinkingSphinx.deltas_enabled = true
        ThinkingSphinx.define_indexes = true
        puts "Resave complete.  Deltas were disabled; you'll need to reindex"
      end
      
    end
  end
  
end

ActiveRecord::Base.send(:extend, CoreExtensions::ActiveRecordExtensions::ClassMethods)
ActiveRecord::Base.send(:include,  CoreExtensions::ActiveRecordExtensions::InstanceMethods)