require 'rubygems'
require 'yaml'

# The ruby task will crash easily. So lots of long interval tasks failed to run in 
# ruby task. This file is supposed to add as system cron, and run it in hourly.
RAILS_ENV = 'production'
RAILS_ROOT = File.join(File.dirname(File.expand_path(__FILE__)), '..')
Dir.chdir(RAILS_ROOT)
require File.join('config', 'environment')

@@config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
@@pk = @@config["ec2_bin_path"] + @@config["pk"]
@@cert = @@config["ec2_bin_path"] + @@config["cert"]

# If the task is not running, restart the application
def job_expire_warning
   lease_warning_time = Time.now + 24 * 60 * 60
   lease_warning_pass = Time.now + 24 * 60 * 60 - 60 * 60
   # Extending 10s to make no job was missing by the cron
   lease_warning_pass = lease_warning_pass - 120
   jobs = Job.find(:all, :conditions =>["state in ('Run', 'PowerOff') and lease_time < :lease_warning_time and lease_time >= :lease_warning_pass",
               {:lease_warning_time => lease_warning_time, :lease_warning_pass => lease_warning_pass}])
   jobs.each do |job|
       content = "Your deployed job " + job.name + " will be expired in 24 hours <br>" 
       content = content + "For more detail please view http://vdi.gdev.com/jobs/" + job.id.to_s
       Email.create_job_notification(job, "Job Lease Warning", content) 
       puts "Job to be expire: " + job.name
   end
end

def calculate_job_cost
  sql = "update jobs
         left join instancetypes
         on jobs.instancetype_id = instancetypes.id
         left join ec2machines
         on jobs.ec2machine_id = ec2machines.id
         set jobs.cost = jobs.cost + (case 
           when ec2machines.platform = 'Windows' and jobs.deploymentway != 'Spot' then instancetypes.windows_price 
           when ec2machines.platform = 'Windows' and jobs.deploymentway = 'Spot' then instancetypes.windows_price * 0.6
           when ec2machines.platform != 'Windows' and jobs.deploymentway != 'Spot' then instancetypes.linux_price
           else instancetypes.linux_price * 0.6 end)
         where jobs.state = 'Run'" 
  ActiveRecord::Base.connection.execute(sql)
end

def send_email_for_cost_warning_jobs
  m = Mutex.new
  m.synchronize do
    jobs = Job.find(:all, :conditions => ["state in ('Run','Capturing') and cost > 50 and cost < 53"])
    jobs.each do |job|
      begin
        cost = job.cost
        instance_type_cose = 0
        warnings = []
        if job.template.platform == 'Windows'
          instance_type_cost = job.instancetype.windows_price 
        else
          instance_type_cost = job.instancetype.linux_price
        end
        if 50 <= cost && cost < 50 +instance_type_cost
          warnings << job
        end
        if warnings.size > 0
          Email.mail_to_admin_about_cost_warning_jobs(warnings)
        end
      rescue Exception => e
        puts "#{e.message} error throw by job id : #{job.id}"
        puts e.backtrace.inspect
      end
    end
  end
end

def close_demo_job
  demojobs = DemoJob.find(:all, :conditions => "state in ('Run', 'Pending')")
  demojobs.each do |demojob|
    begin
      job = demojob.job
      if job.state != "Run" && job.state != "Pending"
        demojob.state = "Undeploy"
        demojob.save
        DemoJob.send_expired_mail(demojob)
      end
    rescue Exception => e
      puts e.backtrace.inspect
    end
  end
end

def demo_lease_warning
  demojobs = DemoJob.find(:all, :conditions => "state in ('Run')")
  lease_warning_time = Time.now + 24 * 60 * 60
  lease_warning_pass = Time.now + 24 * 60 * 60 - 60 * 60
  demojobs.each do |demojob|
    begin
      job = demojob.job
      if job.lease_time <= lease_warning_time && job.lease_time > lease_warning_pass
        DemoJob.send_lease_warning_mail(demojob)
      end
    rescue Exception => e
      puts e.backtrace.inspect
    end
  end
end

# Check lease warning jobs and send mails out to users
puts Time.now.to_s + " job_expire_warning"
job_expire_warning
puts "Calculating the cost of machines"
calculate_job_cost
puts "Send cost warning"
send_email_for_cost_warning_jobs
puts "Close out dated demo jobs"
close_demo_job
puts "Demo lease warning"
demo_lease_warning