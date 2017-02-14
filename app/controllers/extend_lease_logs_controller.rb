class ExtendLeaseLogsController < ApplicationController
  def index
    return if !current_user.is_admin
    @extend_lease_logs = ExtendLeaseLog.all(:include=>:job,:order=>"id desc")
  end
end
