class Software < ActiveRecord::Base
  has_many :license_requests
  has_and_belongs_to_many :templates,:class_name => "Template", :join_table => 'templates_softwares'
  
  def get_license_active_count
    job_licenses_count = Job.find_by_sql("select count(jobs.id) AS active_count FROM jobs LEFT JOIN templates tp ON jobs.template_id = tp.id LEFT JOIN templates_softwares tp_sft ON tp.id = tp_sft.template_id WHERE jobs.state IN ('Deploying','Open','PowerOFF','Run') AND tp_sft.software_id = #{self.id}")[0].active_count.to_i
    user_licenses_count = LicenseRequest.find_by_sql("SELECT SUM(count) AS active_count FROM license_requests WHERE status ='active' and software_id = #{self.id}")[0].active_count.to_i
    return user_licenses_count + job_licenses_count
  end
  
  def download_enabled(user)  
    if user.is_admin
      return true
    end
    if !self.open_for_request
      return false
    end
    if self.is_free
      return true
    end
    active_request = LicenseRequest.find(:all, :conditions=>"request_id= #{user.id} and software_id = #{self.id} and status = 'active'")
    if active_request.size > 0
      return true
    end
    
    return false
  end
end