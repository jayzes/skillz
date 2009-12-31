class TabbedNavigationGenerator < Rails::Generator::Base
  attr_accessor :name

  def initialize(*runtime_args)
    super(*runtime_args)
    if args[0].nil?
      puts banner
    else
      @name = args[0].underscore
    end
  end
  
  def manifest
    record do |m|
      if @name 
        m.directory File.join('app/views/tabbed_navigation')
        m.template 'tabbed_navigation.html.erb', File.join('app/views/tabbed_navigation', "_#{@name}.html.erb")
      end
    end
  end
  
  protected 
  
  def banner
    IO.read File.expand_path(File.join(File.dirname(__FILE__), 'USAGE')) 
  end
  
end