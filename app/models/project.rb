class Project < ActiveRecord::Base
  
  validates_presence_of :name
  
  has_many  :needs,   :class_name => 'SkillNeed', :dependent => :destroy
  has_many  :skills,  :through => :needs
  
end
