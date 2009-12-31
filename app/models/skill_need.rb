class SkillNeed < ActiveRecord::Base
  
  validates_presence_of :skill_id
  validates_presence_of :project_id
  
  belongs_to :project
  belongs_to :skill
  
end
