require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  should_have_db_column       :name,      :type => :string
  should_have_db_column       :cas_user,  :type => :string
  
  should_validate_presence_of   :name
  should_validate_uniqueness_of :name
  should_validate_uniqueness_of :cas_user
  
  should_have_many            :talents,   :dependent  => :destroy
  should_have_many            :skills,    :through    => :talents
end
