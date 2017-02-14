#!/usr/bin/env ruby
# This task is used on 2nd machine to improve the performance and stability of the VDI. 
require 'rubygems'
require 'popen4'
require 'daemons'
require 'thread'
require 'time'

RAILS_ENV = 'production'
#RAILS_ENV = 'development'
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
@@deploy_count = 0
@@recover_count = 0
@@schedule2_check_file = @@config["task_checker_file"] + "_2"

def deploy_job(job)
  ScheduleTask.wtire_current_task_time(@@schedule2_check_file)
  if job.configuration_id != nil
    Job.write_user_data(job)
  end
  ScheduleTask.deploy_job(job)
end

def create_instances_task2
  @@deploy_count = @@deploy_count + 1
  puts "Deploy count: " + @@deploy_count.to_s
  
  if @@deploy_count >= 2
    puts "To many deployment process running, skip it"
    @@deploy_count = @@deploy_count - 1
    return
  end

  ScheduleTask.each_job("('Pending')") do |index, job, pending_jobs_count|
    if (pending_jobs_count >= 0) and (index == 0)
      if ((job.state == "Run") or (job.state == "Deploying") or (job.state == "Open"))			  
        puts "Skip machine deployment, another task is running"
        next
      end 
      deploy_job(job)
    end
  end

  @@deploy_count = @@deploy_count - 1
end

def recover_dead_deployment
  ScheduleTask.recover_dead_deployment
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
    
    #Create instances 2
    @@scheduler.every("45s") do
      puts Time.now.to_s + "create_instances"      
      # If there is no pending jobs then treat the task works correctly.
      if ScheduleTask.jobs_count("('Pending')")  == 0
        ScheduleTask.wtire_current_task_time(@@schedule2_check_file)
      else
        create_instances_task2
      end
    end
    
    # Sometimes,the deployment will be deadline because of the stability issue of amaone. 
    # this task is used to recover the dead jobs 
    @@scheduler.every("302s") do
      puts Time.now.to_s + "recover dead deployment"
      recover_dead_deployment
    end
    @@scheduler.every("30s") do
      puts Time.now.to_s + "assign_vpc_elasticip"
      ScheduleTask.assign_vpc_elasticip
    end     
    @@scheduler.every("333s") do
      puts Time.now.to_s + "cleanup_vpc_elasticip"
      ScheduleTask.cleanup_vpc_elasticip
    end 
    # Tell the scheduler to perform these jobs until the 
    # process is stopped.
    @@scheduler.join
  rescue => e
    RAILS_DEFAULT_LOGGER.warn "Exception in schedule: #{e.inspect}"
    exit
  end
end
