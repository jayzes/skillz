# Load everything from the core_extensions directory
core_extension_files = File.join(File.dirname(__FILE__),'core_extensions','*.rb')

Dir.glob(core_extension_files).each do |path|
  require path
end