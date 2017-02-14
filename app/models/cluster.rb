class Cluster < ActiveRecord::Base
    has_and_belongs_to_many :configurations
    has_many :locks
    belongs_to :user
    
  def can_access(user)
    if user.is_external && self.user_id != user.id
      return false
    end
    return true
  end
end