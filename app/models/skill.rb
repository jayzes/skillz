class Skill < ActiveRecord::Base
  
  validates_presence_of :name
  
  has_many            :needs,     :class_name => 'SkillNeed', :dependent => :destroy
  has_many            :talents,   :dependent  => :destroy
  has_many            :projects,  :through    => :needs
  has_many            :people,    :through    => :talents
  
end
