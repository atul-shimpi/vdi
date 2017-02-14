class ExtendLeaseLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :job
  validates_length_of :reason, :minimum => 30
  validates_presence_of :old_lease_time,:new_lease_time
  
  DAYS = [1,2,3,4,5,6,7]
end