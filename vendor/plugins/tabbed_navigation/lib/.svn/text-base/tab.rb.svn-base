module TabbedNavigation
  class Tab
    include Highlightable
    include Disableable
    attr_accessor :link, :remote_link, :name, :html, :content

    def initialize(options = {})
      @name = options[:name]
      @content = options[:content]
      @link = options[:link] || {}
      @remote_link = options[:remote_link] || nil
      @request_path = options[:request_path]

      # wrap highlights into an array if only one hash has been passed
      options[:highlights] = [options[:highlights]] if options[:highlights].kind_of?(Hash)
      self.highlights = options[:highlights] || []
      self.disabled_if options[:disabled_if] || proc { false }
      @html = options[:html] || {} 
      @html[:title] = options[:title] 

      yield(self) if block_given?

      self.highlights << @link if link? # it does highlight on itself
      raise ArgumentError, 'you must provide a name' unless @name
    end

    # title is a shortcut to html[:title]
    def title
      @html[:title]
    end

    def title=(new_title)
      @html[:title] = new_title
    end

    # more idiomatic ways to set tab properties
    def links_to(l)
      @link = l
    end

    def links_to_remote(rl); 
      @remote_link = rl; 
      #remote links MUST have a dom_id
      #if not given I'll generate a random one
      @html[:id] ||= "tab_#{rand(99999)}"
    end

    def html_options(html)
      @html = html
    end
    
    def named(name)
      @name = name
    end

    def content
      @content
    end

    def contents(new_content)
      @content = new_content
    end

    def titled(title)
      @html[:title] = title
    end

    def link?
      @link && !@link.empty?
    end
  end
end