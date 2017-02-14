#!/usr/bin/env ruby
require 'rubygems'
require 'popen4'
require 'daemons'
require 'thread'
require 'time'

RAILS_ENV = 'production'
APP_DIR = File.join(File.dirname(File.expand_path(__FILE__)), '..')

# Daemonising changes the pwd to /, so we need to switch 
# back to RAILS_ROOT.
Dir.chdir(APP_DIR)

# Load our Rails environment.
require File.join('config', 'environment')
@@config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
@@database = YAML.load_file(RAILS_ROOT + "/config/database.yml")
@@pk = @@config["ec2_bin_path"] + @@config["pk"]
@@cert = @@config["ec2_bin_path"] + @@config["cert"]
@@schedule3_check_file = @@config["task_checker_file"] + "_3"
@@deploy_count = 0
@@recover_count = 0

# encapsulate into a method so testing would be easier
def update_ec2machine_public_dns
  ScheduleTask.update_ec2machine_public_dns
end

def delete_job_ec2machine_and_update_security_type
  ScheduleTask.delete_job_ec2machine_and_update_security_type
end

#delete securitytype
def delete_security_type
  ScheduleTask.delete_security_type
end

def check_spot_requests(region)
  ScheduleTask.check_spot_requests(region)
end

def deploy_normal_instance(job)
  ScheduleTask.deploy_normal_instance(job)
end

def deploy_job(job)
  wtire_current_task_time
  if job.configuration_id != nil
    Job.write_user_data(job)
  end
  ScheduleTask.deploy_job(job)
end

def create_instances_task
  @@deploy_count = @@deploy_count + 1
  puts "Deploy count: " + @@deploy_count.to_s
  if @@deploy_count >= 3
    puts "To many deployment process running, skip it"
    @@deploy_count = @@deploy_count - 1
    return
  end
  skip_count = 0
  deploying_jobs = Job.find(:all, :conditions => "state in ('Deploying') and (region != 'iland' or region is null)")
  if deploying_jobs.size >= 8 && @@deploy_count > 1
    @@deploy_count = @@deploy_count - 1
    puts "Skipp instance deployments as there are too many jobs in deploying"
    #Only run 1 deploy thread if there are too many deploying jobs
    return
  end
  jobs = Job.find(:all, :conditions => "state in ('Pending', 'Deploying') and (region != 'iland' or region is null)")
  deployed_pending_count = 0
  jobs.each do |job|
    begin
      job = Job.find(job.id)
      if job.state == "Run"
        puts "Skip machine deployment, another task is running"
        next
      end
      if job.state == "Deploying"
        pendingjobs = Job.find(:all, :conditions => "state in ('Pending') and (region != 'iland' or region is null)")
        if pendingjobs.size > 0
          # If there are pending jobs. deploy pending jobs first. 
          # If there is no pening jobs, redeploying deploying job
          next
        else
          # Skip some deploying jobs since others are working on it          
          if skip_count == (@@recover_count + @@deploy_count) || jobs.size <= (@@recover_count + @@deploy_count) 
            skip_count = 0
          else  
            skip_count = skip_count + 1
            puts "Skip deployment: " + job.id.to_s
            next
          end
        end
      end
      if job.state = "Pending"
        deployed_pending_count = deployed_pending_count + 1
        if deployed_pending_count >2 
          puts "Stop deploy pending jobs as to stop this round of cron"
          break
        end
      end
      deploy_job(job)
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
      falsetoprocess(job)
    end
  end
  @@deploy_count = @@deploy_count - 1
end

def wtire_current_task_time
   aFile = File.new(@@schedule3_check_file,"w")
   currentTime = Time.now
   hour = currentTime.hour
   min = currentTime.min
   aFile.puts hour * 60 + min
   aFile.close  
end

# Do not make this process synchronized to avoid the dead task
def cleanup_dead_deployment
  @@recover_count = @@recover_count + 1
  puts "Recover count: " + @@recover_count.to_s
  if @@recover_count >= 2
    puts "To many recover process running, skip it"
    @@recover_count = @@recover_count - 1
    return
  end
  recover_count = 0
  Job.find(:all, :conditions => "state in ('Deploying') and (region != 'iland' or region is null)").each do |job|
    begin
      job = Job.find(job.id)
      if job.state == "Run"
        puts "Skip machine deployment, another task is running"
        next
      end
      if job.state == "Deploying"
        if (job.created_at > Time.now - 11 * 60) && (job.updated_at > Time.now - 2 * 60)
          # If the job deployed less than 11 mins, skip it
          next
        end
      end
      recover_count = recover_count + 1
      if recover_count > 2
        puts "Stop the long running cleanup thread" 
        break
      end
      deploy_job(job)
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
      falsetoprocess(job)
    end
  end
  @@recover_count = @@recover_count - 1
end

def initialec2machine(ec2machine)
  ScheduleTask.initialec2machine(ec2machine)
end

def falsetoprocess(job)
  #remove_securitygroup(job)
  ScheduleTask.falsetoprocess(job)   
end

def connect_telnet_service
  ScheduleTask.connect_telnet_service
end

def run_telnet_commands
  ScheduleTask.run_telnet_commands
end

def recover_dead_deployment
  ScheduleTask.recover_dead_deployment
end

def pending_job_warning
  ScheduleTask.pending_job_warning
end 

def check_volumes
  ScheduleTask.check_volumes
end

def check_snapshots
  ScheduleTask.check_snapshots
end

def check_demo_jobs
  ScheduleTask.check_demo_jobs
end

#iLand tasks
def deploy_ilandmachine
  ScheduleTask.deploy_ilandmachine
end

def get_status_of_vapp
  ScheduleTask.get_status_of_vapp
end

def get_status_of_ilandmachine
  ScheduleTask.get_status_of_ilandmachine
end

def capture_template
  ScheduleTask.capture_template
end

def undeploy_ilandmachine_job
  ScheduleTask.undeploy_ilandmachine
end

def get_status_of_template
  ScheduleTask.get_status_of_template
end

Daemons.run_proc(
  'schedule',
  :dir_mode => :normal, 
  :dir => File.join(APP_DIR, 'log'),
  :multiple => false,
  :backtrace => true,
  :monitor => true,
  :log_output => true
) do    
  begin
    # Initialise the OpenWFE scheduler object.
    require 'rufus/scheduler'
    @@scheduler = Rufus::Scheduler.start_new
    #scheduler.start
    
    ActiveRecord::Base.connection.reconnect! unless ActiveRecord::Base.connection.active?

    # Now assign jobs to the scheduler (see API). For example:
    
    # update ec2machine's public_dns
    @@scheduler.every(@@config["update_dns_interval"]) do
      puts Time.now.to_s + "update dns"
      update_ec2machine_public_dns
    end
    
    #delete job ec2machine,update securitytype
    #@@scheduler.every(@@config["delete_expire_job_interval"]) do
    #  puts Time.now.to_s + "delete_expire_job"
    #  delete_job_ec2machine_and_update_security_type
    #end    
    
    #delete securitygroup
    #@@scheduler.every(@@config["delete_securitygroup_interval"]) do
    #  puts Time.now.to_s + "delete_securitygroup"
    #  delete_security_type
    #end

    #check spot requests
    @@scheduler.every(@@config["check_spot_requests_time"]) do
      puts Time.now.to_s + "check_spot_requests"
      regions = @@config["regions"].split(",")
      for region in regions
        check_spot_requests(region.strip)
      end
    end
    
    #Create instances
    @@scheduler.every("45s") do
      wtire_current_task_time
      
      #puts Time.now.to_s + "create_instances"
      #jobs = Job.find(:all, :conditions => "state in ('Deploying', 'Pending') and (region != 'iland' or region is null)")
      # If there is no pending jobs then treat the task works correctly.
      #if jobs.size == 0
      #  wtire_current_task_time
      #end
      #create_instances_task
    end
    
    
    #Cleanup dead deployments
    @@scheduler.every("30s") do
      puts Time.now.to_s + "cleanup_dead_deployment"
      cleanup_dead_deployment
    end

    # Send warning to admin while there are too many pending jobs, which means vdi is hung...
    @@scheduler.every("100s") do
      puts Time.now.to_s + "pending job warning"
      pending_job_warning
    end

    # Update volume status
    @@scheduler.every("25s") do
      puts Time.now.to_s + "check volumes"
      check_volumes
    end  
    
    # Update snapshot status
    @@scheduler.every("125s") do
      puts Time.now.to_s + "check snapshots"
      check_snapshots
    end
    
    # check_demo_jobs
    @@scheduler.every("5m") do
      puts Time.now.to_s + "check_demo_jobs"
      check_demo_jobs
    end 
    
    # update ilandmachine's message
#    @@scheduler.every(@@config["iland_new_job_interval"]) do
#      puts Time.now.to_s + "get_status_of_vapp"
#      get_status_of_vapp
#    end
#
#    @@scheduler.every(@@config["iland_new_job_interval"]) do
#      puts Time.now.to_s + "deploy_ilandmachine"
#      deploy_ilandmachine
#    end
#    
#    @@scheduler.every(@@config["iland_get_vmstatus_interval"]) do
#      puts Time.now.to_s + "get status of vm"
#      get_status_of_ilandmachine
#    end
#    
#    @@scheduler.every(@@config["iland_capture_template_interval"]) do
#      puts Time.now.to_s + "capture template"
#      capture_template
#    end
#    
#    @@scheduler.every(@@config["iland_undeploy_interval"]) do
#      puts Time.now.to_s + "undeploy template"
#      undeploy_ilandmachine_job
#    end
#    
#    @@scheduler.every(@@config["iland_get_template_status_interval"]) do
#      puts Time.now.to_s + "get status of Template"
#      get_status_of_template
#    end   
    
    @@scheduler.join
  rescue => e
    RAILS_DEFAULT_LOGGER.warn "Exception in schedule: #{e.inspect}"
    exit
  end
end