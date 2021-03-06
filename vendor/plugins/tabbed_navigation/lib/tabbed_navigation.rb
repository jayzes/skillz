module TabbedNavigation
  class TabbedNavigation
    attr_accessor :tabs, :html, :name, :separator

    def initialize(name, options = {})
      @name = name || :main
      @tabs = []
      @html = options[:html] || {} # setup default html options
      @separator = options[:separator] || ''
      @html[:id] ||= name.to_s.underscore << '_tabbed_navigation'
      @html[:class] ||= @html[:id].gsub('_', '-')
    end
  end

  module TabbedNavigationHelper
    def tabbed_navigation(name, options = {}, path = nil, &block)
      html = capture { render :partial => (options[:partial] || "tabbed_navigation/#{(path ? path.to_s + '/' : '') + name.to_s}") }
      if block_given?
        options = {:id => @_tabbed_navigation.html[:id] + '_content', :class => @_tabbed_navigation.html[:class] + '-content'}
        html << tag('div', options, true)
        html << capture(&block)
        html << '</div>'
        concat(html, block.binding)
        nil
      else
        return html
      end
    end

    def tabbed_subnavigation_for(name, options = {})
      raise ArgumentError, "Missing name parameter in tabbed_subnavigation_for call" unless name
      html = capture { render :partial => (options[:partial] || "#{options[:path]}/#{name}") }
      options[:partial] = nil;
      @_tabbed_navigation.tabs.each do |tab|
        if tab.highlighted?(params)
          if File.exist?(File.join(RAILS_ROOT, 'app', 'views', "#{options[:path]}/#{name}/_#{tab.name.downcase}.erb"))
            return (options[:title] ? "<h2><span>#{tab.name.singularize} </span>#{options[:title]}</h2>" : '') +
              capture { render(:partial => "#{options[:path]}/#{name}/#{tab.name.downcase}") }#tabbed_navigation(tab.name.downcase, options = {}, name)
          end
        end
      end
      nil
    end

    def render_tabbed_navigation(name, options = {}, &proc)
      raise ArgumentError, "Missing name parameter in tabbed_navigation call" unless name
      raise ArgumentError, "Missing block in tabbed_navigation call" unless block_given?
      @_tabbed_navigation = TabbedNavigation.new(name, options)
      @_binding = proc.binding # the binding of calling page

      instance_eval(&proc)
      out tag('div', @_tabbed_navigation.html, true)
      render_tabbed_navigation_tabs
      out "</div>\n"
      nil
    end

    def add_tab(options = {}, &block)
      raise 'Cannot call add_tab outside of a render_tabbed_navigation block' unless @_tabbed_navigation
      if options[:with_staging] && options[:link] && controller.controller_name == 'staging'
        link = {:controller => 'staging', :action => 'show', :view => "#{options[:link][:controller]}#{options[:link][:action] ? '_' + options[:link][:action] : ''}"}
        options[:highlights] = options[:highlights] ?
          options[:highlights].is_a?(Array) ?
            options[:highlights] << link :
            [options[:highlights], link] :
          link
        options[:link] = link
      end
      options[:request_path] = request.path;
      @_tabbed_navigation.tabs << Tab.new(options, &block)
      nil
    end

    # inspects controller names
    def controller_names
      files = Dir.entries(File.join(RAILS_ROOT, 'app/controllers'))
      controllers = files.select {|x| x.match '_controller.rb'}
      return controllers.map {|x| x.sub '_controller.rb', ''}.sort
    end

    # renders the tabbed_navigation's tabs
    def render_tabbed_navigation_tabs
      out tag('ul', {}, true)

      @_tabbed_navigation.tabs.each do |tab|
        li_options = {}
        li_options[:id] = "#{tab.html[:id]}_container" if tab.html[:id]

        if tab.disabled?
          tab.html[:class] = 'disabled'
        elsif tab.highlighted?(params)
          tab.html[:class] = 'active'
          li_options[:class] = 'active'
        end

        out tag('li', li_options, true)
        if tab.disabled? || (tab.link.empty? && tab.remote_link.nil?)
          out content_tag('span', tab.content || tab.name, tab.html)
        elsif !tab.link.empty?
          out link_to(tab.content || tab.name, tab.link, tab.html)
        elsif tab.remote_link
          success = "document.getElementsByClassName('active', $('" + @_tabbed_navigation.html[:id]+ "')).each(function(item){item.removeClassName('active');});"
          success += "$('#{tab.html[:id]}').addClassName('active');"
          # success += "alert(this);"

          remote_opts = {:update => @_tabbed_navigation.html[:id] + '_content',
           # :success => success,
            :method => :get,
            :loading => loading_function + success,
            :loaded => "$('#{@_tabbed_navigation.html[:id]}_content').setStyle({height: 'auto'});"
          }
          out link_to_remote(tab.content || tab.name, remote_opts.merge(tab.remote_link), tab.html)
        else
        end
        out @_tabbed_navigation.separator unless tab == @_tabbed_navigation.tabs.last
        out '</li>'
      end
      out '</ul>'
    end

    def out(string)
      concat(string)
    end

    # generate javascript function to use while loading remote tabs
    def loading_function
#      # show customized partial and adjust content height
#      # todo: find out why I need a 38px offset :-|
#      begin
#        inner_html = capture {render :partial => 'shared/tabnav_loading' }
#      rescue
#        inner_html = "Loading..."
#      end
#      return <<-JAVASCRIPT
#          var element = $('#{@_tabbed_navigation.html[:id]}_content');
#          var h = element.getHeight() - 38;
#          element.innerHTML='#{escape_javascript(inner_html)}';
#          element.setStyle({height: ''+h+'px'});
#          //element.morph('height:'+h+'px');
#      JAVASCRIPT
    end
  end
end
