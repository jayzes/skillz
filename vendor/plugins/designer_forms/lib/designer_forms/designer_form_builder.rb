=begin
  TODO: still debating if I should break all these out into different files -- the argument is
        about keeping all related things in one file (easy to find stuff) vs. breaking it out
        into sensible groups.  Leave your thoughts.
=end

module Kernel

  # Figures out which form_for method is calling our fields_for method, but can be used for other
  # situations as well.
  def caller_method(level = 1)
    caller[level] =~ /`([^']*)'/ and $1
  end

  # Provides a handy trace style method that you can use anywhere.
  def log_trace(message)
    custom_logger = Logger.new('log/trace.log')
    custom_logger.add(Logger::INFO, "#{Time.now} in #{caller[0]}:\n#{message}\n")
  end

end

module DesignerForms # :nodoc:
  module HelperExtensions # :nodoc:

    class DesignerFormBuilder < ActionView::Helpers::FormBuilder
      
      include ActionView::Helpers::FormTagHelper
      include ActionView::Helpers::CaptureHelper
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::TextHelper
      
      # Allows for form instance level configuration.
      @@form_options = DesignerFormsConfig.clone
      cattr_accessor :form_options
      attr_writer :form_options

      def logger
        RAILS_DEFAULT_LOGGER
      end

      # Wraps a given string in the configurable input_wrapper_tag and adds the various class names
      # based on if the field is required or has errors.  Also makes the
      # wrap_input_with_designerization a little nicer to use, and standard.
      def wrap_input(field, input, options = {})
        # figures out if the field is actually required or not by reflection or if it was required
        # in the form_options
        is_required = (@object && @object.class.requires?(field) || options[:required] == true)
        logger.debug("wrap_input = is_required #{is_required}")
        # creates the class attribute based on various information
        add_class!(options, @@form_options.required_class) if is_required
        add_class!(options, @@form_options.error_class) if has_errors?(field, options[:include_errors_for])
        options.delete(:required)
        options.delete(:include_errors_for)
        add_class!(options, "input-container")
        logger.debug("wrap_input = options #{options.inspect}")
        @template.content_tag(@@form_options.input_wrapper_tag, input, options.merge!(:id => "#{field}_container"))
      end
      alias_method :wrap_input_with_designerization, :wrap_input

      # Builds an error message for a given input field if there are in fact any errors.
      def errors_for(field, extra_fields = nil)
        field = field.to_sym
        return '' if !has_errors?(field, extra_fields) && !@@form_options._validates_with_ajax
        fields = extra_fields.is_a?(Array) ? [field] + extra_fields : [field]

        error_messages = []
        fields.each do |f|
          f = @object.errors[f] ? f : f.to_s.gsub(/_id$/, '').to_sym
          error_message = @object.errors[f].is_a?(Array) ?
            @object.errors[f].to_sentence(:skip_last_comma => true) :
            @object.errors[f]
          error_messages << error_message unless error_message.blank?
        end

        error_messages.blank? ?
          @@form_options.errors_for_input_wrapper.gsub(/\$\{html_tag\}/, '').gsub(/\$\{field\}/,  field.to_s) :
          @@form_options.errors_for_input_wrapper.gsub(/\$\{html_tag\}/, @@form_options.errors_for_input_sub_wrapper.to_s.gsub(/\$\{html_tag\}/, error_messages.to_sentence(:skip_last_comma => true).humanize)).gsub(/\$\{field\}/, field.to_s)

      end
      
      # Returns a boolean based on if the requested field has errors or not.
      def has_errors?(field, extra_fields = nil)
        field = field.to_sym
        fields = extra_fields.is_a?(Array) ? [field] + extra_fields : [field]
        count = 0;
        fields.each {|f| count = count + 1 if @object && (@object.errors[f.to_sym] || @object.errors[f.to_s.gsub(/_id$/, '').to_sym]) }
        count > 0 ? count : false;
      end
      
      # In another effort to create some sensible grouping, I put this into the form instance as
      # well.  This just calls through to the ActionView::Helpers::FormTagHelper.field_set_tag
      # chain.
      def field_set(legend = nil, form_options = {}, &block)
        @template.send(:field_set_tag, legend, form_options, &block)
      end

      # Takes over the check_box method, because the order of the args is dumb.
      def check_box_with_proper_args(method, checked_value = "1", unchecked_value = "0", form_options = {})
        check_box_without_proper_args(method, form_options, checked_value, unchecked_value)
      end
      alias_method_chain :check_box, :proper_args

      # Builds the ajax validation that typically is used in the onblur attribute of input elements.
      def ajax_validation(field, with = nil)
        path = @template.controller.url_for(:action => 'ajax_validate', :only_path => true)
        with = "['#{with.is_a?(Array) ? with.join("','") : with.to_s}']"
        "AjaxValidator.validateField('#{path}', '#{@object_name}', '#{field}', #{with})"
      end
      
      # Creates the with/without designerized input helper methods.  These new methods add
      # additional flexibility to the already good helper methods.  This makes them better and a
      # little more configurable.
      def self.create_designerized_method!(method_name)
        # overrides the input helper by creating a new method
        define_method("#{method_name}_with_designerization") do |field, *args|
          form_options = args.last.is_a?(Hash) ? args.pop : {}
          @object = @template.instance_variable_get("@#{@object_name}") if @object.nil?
          # figures out if the field is actually required or not by reflection or if it was
          # required in the form_options
          logger.debug "*** @object #{@object}"
          logger.debug "*** @object.class.requires?(field) #{field} => #{@object.class.requires?(field)}" if @object
          is_required = (@object && @object.class.requires?(field)) || form_options[:required] == true
          
          # # makes sure we actually have an object to validate on


          # gets the tip out of the form_options, because we want it as a title attribute, not as a tip
          tip = form_options.delete(:tip)
          form_options[:title] = tip if tip && !form_options[:title]

          # adds the javascript onblur attribute for ajax validation if it's being used
          form_options[:onblur] = ajax_validation(field, form_options[:validate_with]) if @@form_options._validates_with_ajax
          form_options.delete(:validate_with)
          form_options.delete(:without_ajax_validation)

          #ApplicationHelper.designer_form_builder_callback(method_name, @object, @@form_options) # if respond_to?(:designer_form_builder_callback)
          add_class!(form_options, 'text') if %w{ text_field password_field text_area calendar_date_select }.include?(method_name)

          # gets the input tag, and adds a span wrapper for checkboxs and radio buttons
          passed_form_options = form_options.clone
          passed_form_options.delete(:required)
          passed_form_options.delete(:label)
          passed_form_options.delete(:include_errors_for)
          args = (args << passed_form_options)
          args << {:onblur => form_options[:onblur]} if @@form_options._validates_with_ajax && %w{ collection_select }.include?(method_name)
          html_tag = %w{ check_box radio }.include?(method_name) ?
            @template.content_tag(:span, send("#{method_name}_without_designerization", field, *args), :class => 'form_options') :
            send("#{method_name}_without_designerization", field, *args)

          # adds the error messages if it should be
          error_fields = form_options[:include_errors_for]
          html_tag += errors_for(field, error_fields) if (has_errors?(field, error_fields) && @@form_options.include_errors_with_input) || @@form_options._validates_with_ajax
          
          # adds the input tip if it should be
          html_tag += @@form_options.tip_wrapper.gsub(/\$\{html_tag\}/, tip).gsub(/\$\{field\}/, field.to_s) if !has_errors?(field, error_fields) && tip
          
          # creates and returns the wrapper tag, passing in the label, input and other various html
          return %w{ check_box radio }.include?(method_name) ?
            wrap_input(
              field,
              html_tag + label(field, form_options[:label] || "#{field.to_s.humanize}:", {:required => is_required}),
              {:required => is_required, :include_errors_for => error_fields}) :
            wrap_input(
              field,
              label(field, form_options[:label] || "#{field.to_s.humanize}:", {:required => is_required}) + html_tag,
              {:required => is_required, :include_errors_for => error_fields})

        end
        
        # chains the methods together
        alias_method_chain method_name, :designerization
      end

      # Creates a designerized version of the label method, which is needed for marking the label
      # as required if the field is required.
      def label_with_designerization(field, text = nil, form_options = {})
        text = text || "#{field.to_s.humanize}:"
        
        # figures out if the field is required and adds a class, and the required flag
        if (@object && @object.class.requires?(field)) || form_options[:required] == true
          text = @@form_options.required_flag + text
          add_class!(form_options, @@form_options.required_class)
        end
        form_options.delete(:required)
        form_options.delete(:label)
        
        self.respond_to?(:label_without_designerization) ?
          label_without_designerization(field, text, form_options) :
          @template.content_tag(:label, text, form_options.merge!('for' => "#{@object_name}_#{field}"))
      end
      self.respond_to?(:label) ?
        alias_method_chain(:label, :designerization) : 
        alias_method(:label, :label_with_designerization)

      # Redefines each field helper method so that they'll get the designer treatment.
      @@form_options.input_helper_methods.each do |name| 
        create_designerized_method!(name) #if self.respond_to?(name)
      end

      # Changes the default way error fields get wrapped to use the configuration error_wrapper.
      ActionView::Base.field_error_proc = Proc.new{|html_tag, instance| @@form_options.error_wrapper.gsub(/\$\{html_tag\}/, html_tag) }
    end

    # Chains the designer form_for and fields_for methods, which allows you to call form_for, or
    # fields_for to get one with designerization by default, or if you'd rather have the old, 
    # unstyled way, you can call form_for_without_designerization or
    # fields_for_without_designerization respectively.
    module ActionView::Helpers::FormHelper

      # Creates the designerized version of the form_for method.
      def form_for_with_designerization(name, *args, &block)
        form_options = args.last.is_a?(Hash) ? args.pop : {}
        
        # adds the default form class for form styling
        form_options[:html] = form_options[:html] || {}
        add_class!(form_options[:html], DesignerFormsConfig.form_class)
        form_options[:html][:id] = form_options[:html][:id] || "#{name}_form"
        
        # figure out if this form validates field by field using ajax
        DesignerFormsConfig._validates_with_ajax = form_options[:validates_with_ajax]

        # re-adds form_options back to args and calls the original form_for method
        args = (args << form_options)

        # do some wrapping for the form output
        wrapper = DesignerFormsConfig.form_wrapper.split('${html_tag}')
        concat(wrapper.first)
        form_for_without_designerization(name, *args, &block)
        concat(wrapper.length > 1 ? wrapper.last : '')
      end
      
      # Creates the designerized version of the fields_for method.
      def fields_for_with_designerization(name, *args, &block)
        form_options = args.last.is_a?(Hash) ? args.pop : {}
        
        # add builder to form to have the inputs auto styled
        if !form_options[:builder]
          builder = DesignerFormsConfig.builder.constantize
          builder.form_options._validates_with_ajax = form_options[:validates_with_ajax]
        end
        form_options = form_options.merge(:builder => form_options[:builder] || builder)

        # re-add form_options back to args and call the original fields_for method
        # NOTE: fields_for gets called from form_for so see if it is the aliased version and if it
        #       is, we don't want to pass the additional form_options in
        args = (args << form_options) unless caller_method =~ /^form_for_without/ && !(caller_method(2) =~ /^form_for/)
        fields_for_without_designerization(name, *args, &block)
      end
      
      # Create the method chains for the designerized and non-designerized methods.
      %w{ form_for fields_for }.each {|method_name| alias_method_chain method_name, :designerization }
      
    end

    # As a matter of principle, this creates a new field_set_tag method that does in fact take html
    # form_options as a param, so this creates a nicer designerized version in case you should ever want
    # to pass in some html form_options -- like class, id and whatnot.
    module ActionView::Helpers::FormTagHelper

      # Adds or merges a class html attribute to a given hash.
      def add_class!(options, new_class)
        options[:class] = options[:class] && options[:class].split(' ').include?(new_class) ?
          options[:class] :
          [options[:class], new_class].compact * ' '
      end
      
    end

    # Creates a better and more configurable designerized version of the error_messages_for.
    module ActionView::Helpers::ActiveRecordHelper

      def error_messages_for_with_designerization(*args)
        form_options = args.last.is_a?(Hash) ? args.pop : {}

        objects = (object = form_options.delete(:object)) ?
          [object].flatten :
          args.collect {|object_name| instance_variable_get("@#{object_name}") }.compact

        simple_errors = DesignerFormsConfig.include_errors_with_input
        count = objects.inject(0) {|sum, obj| sum + obj.errors.count }
        unless count.zero?
          form_options[:object_name] ||= args.first

          html_form_options = form_options[:html] || {}
          html_form_options[:class] = form_options.include?(:class) ? form_options[:class] : DesignerFormsConfig.error_list_class
          html_form_options[:id] = form_options.include?(:id) ? form_options[:id] : "errors_for_#{form_options[:object_name].to_s}"

          form_options[:header_message] = "#{pluralize(count, 'error')} prohibited this #{form_options[:object_name].to_s.gsub('_', ' ')} from being saved" unless form_options.include?(:header_message) || simple_errors && form_options.include?(:disable_header_message)
          form_options[:message] ||= 'There were problems with the following fields:' unless form_options.include?(:message) || simple_errors
          error_messages = objects.map {|obj| obj.errors.full_messages.map {|msg| content_tag(DesignerFormsConfig.error_list_item_wrapper_tag, msg) } }

          contents = ''
          contents << content_tag(form_options[:header_tag] || :h2, form_options[:header_message]) unless form_options[:header_message].blank?
          contents << content_tag(:p, form_options[:message]) unless form_options[:message].blank?
          contents << content_tag(DesignerFormsConfig.error_list_wrapper_tag, error_messages) unless simple_errors
          content_tag(:div, contents, html_form_options)
        else
          ''
        end
      end
      alias_method_chain :error_messages_for, :designerization

    end

  end
end