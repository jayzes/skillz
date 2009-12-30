require 'test_helper'

class <%= class_name %>ControllerTest < ActionController::TestCase
  context '<%= class_name.underscore %> controller' do
  <% for action in ( actions || ['index'] ) %>
    context 'GET <%= action %>' do
      setup { get :<%= action %> }
      
      should_respond_with :success
      should_render_template :<%= action %>
      should_not_set_the_flash
    end
  <% end -%>
  end
end
