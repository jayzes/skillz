require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  should_have_db_column       :name, :type => :string
  
  should_validate_presence_of :name
  
  should_have_many            :needs,   :dependent  => :destroy
  should_have_many            :skills,  :through    => :needs
end
