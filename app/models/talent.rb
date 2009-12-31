class Talent < ActiveRecord::Base
  
  validates_presence_of :skill_id
  validates_presence_of :person_id
  
  belongs_to :skill
  belongs_to :person
  
end
