require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  should_have_db_column       :name,      :type => :string
  should_have_db_column       :cas_user,  :type => :string
  
  should_validate_presence_of :name
  
  should_have_many            :talents,   :dependent  => :destroy
  should_have_many            :skills,    :through    => :talents
end
