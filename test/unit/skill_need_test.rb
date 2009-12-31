require 'test_helper'

class SkillNeedTest < ActiveSupport::TestCase

  should_have_db_column       :skill_id,    :type => :integer
  should_have_db_column       :project_id,  :type => :integer
  
  should_validate_presence_of :skill_id
  should_validate_presence_of :project_id
  
  should_belong_to :project
  should_belong_to :skill
  
end
