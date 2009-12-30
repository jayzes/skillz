require 'ostruct'
require 'yaml'

# Load plugin configuration.
#
# To use a configuration, create a file at /config/plugins/designer_forms.yml and it will get
# loaded automatically.  If a file doesn't exist at that location the default plugin config.yml
# will be loaded.  The easiest way is to copy the config.yml file to your /config/plugins path
# changing it's name and modifying whatever you'd like.
# 
# "common" will be loaded for all environments, while the values in whatever RAILS_ENV will
# override any that might have been also defined in "common".
CONFIG_PATH = File.file?(File.join(RAILS_ROOT, 'config', 'plugins', "#{name}.yml")) ?
    File.join(RAILS_ROOT, 'config', 'plugins', "#{name}.yml") : "#{directory}/config.yml"
config = YAML.load(ERB.new(File.read(CONFIG_PATH)).result)
::DesignerFormsConfig = OpenStruct.new(
  config.key?(RAILS_ENV) ?
    config.key?('common') ? config['common'].merge!(config[RAILS_ENV]) : config[RAILS_ENV] :
    config.key?('common') ? config['common'] : {}
  )

# The DesignerFormBuilder, once included will hijack the form_for and fields_for methods to add
# additional styling and handling.  It also adds some helpers that you might find handy.
require 'designer_forms/designer_form_builder'

# The Ajax Validation is an add-on for the DesignerFormBuilder and does field level validation
# when you tab off of fields.
require 'designer_forms/ajax_validation'
ActionController::Base.class_eval do
  include ActionController::Macros::AjaxValidation
end

# This adds validation reflection to the ActiveRecord objects.  The idea is for better form
# validation and more specifically adds the ability for field level validation on the fly.
require 'designer_forms/validation_reflection'
ActiveRecord::Base.class_eval do
  include DesignerForms::ActiveRecordExtensions::ValidationReflection
  DesignerForms::ActiveRecordExtensions::ValidationReflection.load_config
  DesignerForms::ActiveRecordExtensions::ValidationReflection.install(self)
end
