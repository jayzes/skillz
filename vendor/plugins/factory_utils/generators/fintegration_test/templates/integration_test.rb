require 'test_helper'

class <%= class_name %>Test < ActionController::IntegrationTest

  context '<%= class_name.underscore %> integration' do
    # Replace this with your real tests.
    should "the truth" do
      assert true
    end 
  end
  
end
