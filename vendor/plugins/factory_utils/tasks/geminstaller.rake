
namespace :geminstaller do
  desc "run geminstaller to install required gems"
  task :run do
    ############# Begin GemInstaller config - see http://geminstaller.rubyforge.org
    require "rubygems" 
    require "geminstaller" 

    # Path(s) to your GemInstaller config file(s)
    config_paths = "#{File.expand_path(RAILS_ROOT)}/config/geminstaller.yml" 

    # Arguments which will be passed to GemInstaller (you can add any extra ones)
    args = "--config #{config_paths}" 
    
    args += ",#{File.expand_path(RAILS_ROOT)}/config/geminstaller.local.yml" unless ENV['REMOTE'] == 'true'

    # The 'exceptions' flag determines whether errors encountered while running GemInstaller
    # should raise exceptions (and abort Rails), or just return a nonzero return code
    args += " --exceptions" 
    
    # args += "--geminstaller-output=all"

    # This will use sudo by default on all non-windows platforms, but requires an entry in your
    # sudoers file to avoid having to type a password.  It can be omitted if you don't want to use sudo.
    # See http://geminstaller.rubyforge.org/documentation/documentation.html#dealing_with_sudo
    args += " --sudo" unless RUBY_PLATFORM =~ /mswin/ || ENV['USE_SUDO'] == 'false'

    # The 'install' method will auto-install gems as specified by the args and config
    # puts args 
    GemInstaller.run(args)

    # The 'autogem' method will automatically add all gems in the GemInstaller config to your load path, using the 'gem'
    # or 'require_gem' command.  Note that only the *first* version of any given gem will be loaded.
    # GemInstaller.autogem(args)
    ############# End GemInstaller config
  end
  
end