class Group < ActiveRecord::Base
#  validates_presence_of :manager_id, :message=>"selection is mandatory!!"
  has_and_belongs_to_many :users
  has_many :jobs
  
  def self.managed_groups(user)
    return Group.find(:all, :conditions=> "manager_id = #{user.id}")
  end
  
  #return ture if A is the manager of B
  def self.is_manager(a, b)
    a_managed = managed_groups(a)
    b_groups = b.groups
    if (a_managed & b_groups).size > 0
      return true
    else
      return false
    end
  end
end