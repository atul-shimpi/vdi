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

def send_week_ahead_lease_warning
  begin
    Job.find(:all, :conditions => "DATEDIFF(NOW(),created_at) >= 53 and DATEDIFF(lease_time, NOW()) <= 7 and  state IN ('Run','PowerOFF', 'Capturing')").each do |job|
      subject = "Your long term job will be expired soon -- " + job.id.to_s
      subject += " " + job.user.name if job.user
      content = "Your long term job will be expired at " + job.lease_time.to_s
      content = content + ". Please contact VDI admin team if you need extend the job. " 
      content = content + "http://vdi.gdev.com/jobs/" + job.id.to_s
      owner_email = job.user.email
      Email.send_lease_warning(subject, content,owner_email)
    end
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
  end    
end

def send_warning_mail
  state = "('" + Job::STATUS[:active].join("','")+"')" 
  jobs = Job.find(:all, :conditions=> ["cost > 100 and state in "+ state])
  if jobs.size > 0
    subject = "Jobs with cost more then $100"
    content = "<table>"
    jobs.each do |job|
      content = content + "<tr><td> Job ID:" +job.id.to_s + "</td><td> Job Name:" + job.name + "</td></tr>"
    end
    content = content + "</table>"
    Email.mail_to_admin(subject,content)
  end
end

def dead_job_warning_mail
  state = "('" + Job::STATUS[:active].join("','")+"')"
  jobs = Job.find(:all,:joins => "join users u on u.id = jobs.user_id join ec2machines e on e.id = jobs.ec2machine_id", :conditions=> "u.disabled = 1 AND state in "+state)
  if jobs.size > 0
    subject = "Active jobs from disabled user"
    content = "<table>" 
    jobs.each do |job|
      content = content + "<tr><td>Job ID : " + job.id.to_s + "</td> <td>Job Name : " + job.name + "</td> <td>Public DNS : " + job.ec2machine.public_dns.to_s + "</td> <td>Cost : " + job.cost.to_s + "</td> <td>Owner account " + job.user.account + " </td> <td>Owner mail " + job.user.email + "</td></tr>"    
    end
    content = content + "</table>"
    Email.mail_to_admin(subject,content)
  end
end

send_week_ahead_lease_warning
send_warning_mail
dead_job_warning_mail