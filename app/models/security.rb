class Security < ActiveRecord::Base
  has_and_belongs_to_many :jobs
  belongs_to :securitygroups
end
