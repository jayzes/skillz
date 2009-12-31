class Person < ActiveRecord::Base
  
  validates_presence_of :name
  
  has_many  :talents,   :dependent  => :destroy
  has_many  :skills,    :through    => :talents
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
  
end
