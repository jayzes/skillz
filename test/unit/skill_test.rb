require 'test_helper'

class SkillTest < ActiveSupport::TestCase

  should_have_db_column       :name, :type => :string
  
  should_validate_presence_of :name
  
  should_have_many            :needs,     :dependent => :destroy
  should_have_many            :talents,   :dependent => :destroy
  
  should_have_many            :projects,  :through => :needs
  should_have_many            :people,    :through => :talents
end
