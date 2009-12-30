require 'test_helper'

class <%= class_name %>Test < ActiveSupport::TestCase
  
  should_have_valid_factory :<%= file_name %>
  <% attributes.select(&:reference?).each do |attribute| -%>
  should_belong_to :<%= attribute.name %>
  <% end -%>
  
end
