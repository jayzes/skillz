desc 'Print out all defined routes in match order, with names.'
task :routes => :environment do
  controller = ENV['controller']
  # puts "controller=#{controller}"
  routes = ActionController::Routing::Routes.routes.select do |route| 
    controller.nil? || controller == route.requirements[:controller]
  end
            
  routes = routes.collect do |route|
      name = ActionController::Routing::Routes.named_routes.routes.index(route).to_s
      verb = route.conditions[:method].to_s.upcase
      segs = route.segments.inject("") { |str,s| str << s.to_s }
      segs.chop! if segs.length > 1
      reqs = route.requirements.empty? ? "" : route.requirements.inspect
      {:name => name, :verb => verb, :segs => segs, :reqs => reqs}
  end
  # get maximum widths for column output
  width = routes.inject({}) do |w, r|
    r.each do |key, value|
      len = value.length
      w[key] = len unless w[key].to_i > len
    end
    w
  end

  # predefined ANSI color codes for HTTP verbs
  colors = { "POST" => '35;1', "PUT" => '36;1', "DELETE" => '31;1' }

  String.class_eval do
    if RUBY_PLATFORM.index('mswin').nil?
      def colorize(code)
        code ? "\e[#{code}m#{self}\e[0m" : self
      end
    else
      begin
        require 'Win32/Console/ANSI'
        def colorize(code)
          code ? "\e[#{code}m#{self}\e[0m" : self
        end
      rescue LoadError
        def colorize(code) self end
      end
    end
  end
  
  routes.each do |r|
    puts [ r[:name].rjust(width[:name]).colorize('1'),
               r[:verb].ljust(width[:verb]).colorize(colors[r[:verb]]),
               r[:segs].ljust(width[:segs]).gsub(/:\w+/){|m| m.colorize('36') },
               r[:reqs]
             ].join(' ')
  end
end

desc 'Routes listed in a browser.'
task :routes_page => :environment do
  require 'erb'
  include ERB::Util
  @routes = ActionController::Routing::Routes.routes.collect do |route|
    name = ActionController::Routing::Routes.named_routes.routes.index(route).to_s
    verb = route.conditions[:method].to_s.upcase
    segs = route.segments.inject("") { |str,s| str << s.to_s }
    reqs = route.requirements.inspect
    {:name => name, :verb => verb, :segs => segs, :reqs => reqs}
  end
  
  template = <<-END_ERB
<html><head><title>Rails Routes</title></head>
<body>
<table>
<% @routes.each do |r| %>
  <tr<%= r[:name] =~ /^formatted_/ ? ' style="color: gray"' : "" %>>
    <td style="padding-right: 1em" align="right"><%= h r[:name] %></td>
    <td style="padding-right: 1em"><%= h r[:verb] %></td>
    <td style="padding-right: 1em"><%= h r[:segs] %></td>
    <td><%= h r[:reqs] %></td>
  </tr>
<% end %>
</table>
</body></html>
END_ERB

  ERB.new(template).run(binding)

end
