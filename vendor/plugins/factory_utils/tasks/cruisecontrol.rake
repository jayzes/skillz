require 'ftools'

desc "Run the build for CruiseControl.rb"
task :cruise => 'cruise:db_prep' do
  Rake::Task['test'].invoke
end

namespace :cruise do
  
  desc "Run the build for CruiseControl.rb with metrics"
  task :metrics => :db_prep do
    require 'metric_fu'
    Rake::Task['metrics:all'].invoke
  end
  
  desc "Prepare the database"
  task :db_prep => :copy_database_yml do
    Rake::Task['db:create:all'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:test:prepare'].invoke
  end
  
  desc "Copy database.cruisecontrol.yml into place"
  task :copy_database_yml do
    # copy the right database.yml
    if File.exists?(Dir.pwd + "/config/database.cruisecontrol.yml")
      File.copy(Dir.pwd + "/config/database.cruisecontrol.yml",Dir.pwd + "/config/database.yml")
    end
  end
  
  desc 'Set up the basic config for CruiseControl'
  task :setup do
    File.copy(File.join(RAILS_ROOT,'vendor','plugins','factory_utils','examples','cruisecontrol','build.sh'), RAILS_ROOT)
    File.copy(File.join(RAILS_ROOT,'vendor','plugins','factory_utils','examples','cruisecontrol','cruise_config.rb'), RAILS_ROOT)
    File.copy(File.join(RAILS_ROOT,'vendor','plugins','factory_utils','examples','cruisecontrol','database.cruisecontrol.yml'), File.join(RAILS_ROOT,'config'))
    puts "A basic build.sh and cruise_config.rb have been copied to the project's root directory, and an example database.cruisecontrol.yml has been copied to the config/ directory."
    puts "You'll need to do a few more steps manually to get your project set up in CI:"
    puts " - Uncomment and modify the notification e-mail addresses on line 6 of cruise_config.rb to reflect your project team"
    puts " - Change the database names in database.cruisecontrol.yml to reflect your application's name.  The username and password should not change."
    puts " - Add database.cruisecontrol.yml, cruise_config.rb, and build.sh to SVN and commit them"
    puts " - Finally, add your project to the CI server.  You'll need to SSH to interactive@ci.factorylabs.com and run the following command:"
    puts "       cd /cruise && ./cruise add <project name> --repository <full path to SVN repository trunk> --username <SVN username> --password <SVN password> && sudo /etc/init.d/ccrb restart"
    puts "After that command completes, you should be able to go to http://ci.factorylabs.com/ and see your project listed.  It will automatically check SVN every 30 seconds, checkout and build the project if the source has changed, and send you an e-mail if there are any failures."
  end
end