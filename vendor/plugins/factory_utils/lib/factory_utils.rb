require 'factory_design_labs/kernel'
require 'factory_design_labs/environment_helpers'
require 'factory_design_labs/has_parent_resource'
require 'core_extensions'

if RAILS_ENV == 'test'
  require 'testing/utility_methods'
  require 'test_unit'
  ActiveRecord::Base.send :include, Testing::Syntax::ActiveRecord
end
