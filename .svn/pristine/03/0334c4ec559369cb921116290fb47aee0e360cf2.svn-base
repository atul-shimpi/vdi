class LicenseRequest < ActiveRecord::Base
  belongs_to :software
  belongs_to :requester, :class_name => "User" , :foreign_key => "request_id"
  belongs_to :approver, :class_name => "User" , :foreign_key => "approval_id"
  


  
end