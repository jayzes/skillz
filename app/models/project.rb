class Project < ActiveRecord::Base
  
  validates_presence_of :name
  
  has_many  :needs,   :class_name => 'SkillNeed', :dependent => :destroy
  has_many  :skills,  :through => :needs
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
  
  def ideal_people
    @ideal_people ||= Person.find(:all, :select => 'people.*, count(*) AS skill_overlap_count',
                                  :conditions => ['projects.id = ?', self.id],
                                  :group => 'people.id',
                                  :order => 'skill_overlap_count DESC', 
                                  :joins => ' INNER JOIN talents ON talents.person_id = people.id 
                                  	          LEFT JOIN skills ON talents.skill_id = skills.id 
                                  	          LEFT JOIN skill_needs ON skill_needs.skill_id = skills.id 
                                  	          LEFT JOIN projects ON skill_needs.project_id = projects.id')
  end
  
  def ideal_people_grouped
    
    @ideal_people_grouped ||= Person.find(:all, :select => 'people.name AS name, skills.name AS skill',
                                  :conditions => ['projects.id = ?', self.id],
                                  :joins => ' INNER JOIN talents ON talents.person_id = people.id 
                                  	          LEFT JOIN skills ON talents.skill_id = skills.id 
                                  	          LEFT JOIN skill_needs ON skill_needs.skill_id = skills.id 
                                  	          LEFT JOIN projects ON skill_needs.project_id = projects.id').group_by(&:name).sort_by { |name, skillset| -1 * skillset.size }
                                  	          
  end
    
end
