module ::Configuration
  def self.create(file)
    instance_eval <<-"end;"
      module ::#{file.to_s.classify}
        class << self
          @app_config
          @file_mtime
          @local_file_mtime
          
          def file_path
            "#{RAILS_ROOT}/config/#{file.to_s}.yml"
          end
          
          def local_file_path
            "#{RAILS_ROOT}/config/#{file.to_s}.local.yml"
          end

          def method_missing(param)
            build_config if can_build_config?
            @app_config.send(param)
          end
          
          def can_build_config?
            @app_config.nil? || 
            @file_mtime && @file_mtime < File.mtime(file_path) ||
            @local_file_path && @local_file_path < File.mtime(local_file_path)
          end

          def build_config
            @app_config = AppConfig.new
            @app_config.use_file!(file_path)
            @file_mtime = File.mtime(file_path)
            
            if File.exists?(local_file_path)
              @app_config.use_file!(local_file_path) 
              @local_file_mtime = File.mtime(local_file_path)
            end
            
            @app_config.use_section!(RAILS_ENV)
          end  
        end          
      end
    end;
  end
end
