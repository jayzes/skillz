require 'test_helper'

class TalentTest < ActiveSupport::TestCase
  
  should_have_db_column       :skill_id,    :type => :integer
  should_have_db_column       :person_id,   :type => :integer
  
  should_validate_presence_of :skill_id
  should_validate_presence_of :person_id
  
  should_belong_to :skill
  should_belong_to :person
  
end
