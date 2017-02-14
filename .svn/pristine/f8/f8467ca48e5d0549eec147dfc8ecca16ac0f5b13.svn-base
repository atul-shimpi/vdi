#!/usr/bin/env ruby
# For iland schedules
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
@@schedule_check_file = @@config["task_checker_file"] + "_iland"

def wtire_current_task_time
   aFile = File.new(@@schedule_check_file,"w")
   currentTime = Time.now
   hour = currentTime.hour
   min = currentTime.min
   aFile.puts hour * 60 + min
   aFile.close  
end

def deploy_ilandmachine  
  ScheduleTask.deploy_ilandmachine
end

def get_status_of_vapp
  ScheduleTask.get_status_of_vapp
end

def get_status_of_ilandmachine
  wtire_current_task_time
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
  'ilandschedule',
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
    
    # update ilandmachine's message
    @@scheduler.every(@@config["iland_new_job_interval"]) do
      puts Time.now.to_s + "get_status_of_vapp"
      get_status_of_vapp
    end

    @@scheduler.every(@@config["iland_new_job_interval"]) do
      puts Time.now.to_s + "deploy_ilandmachine"
      deploy_ilandmachine
    end
    
    @@scheduler.every(@@config["iland_get_vmstatus_interval"]) do
      puts Time.now.to_s + "get status of vm"
      get_status_of_ilandmachine
    end
    
    @@scheduler.every(@@config["iland_capture_template_interval"]) do
      puts Time.now.to_s + "capture template"
      capture_template
    end
    
    @@scheduler.every(@@config["iland_undeploy_interval"]) do
      puts Time.now.to_s + "undeploy template"
      undeploy_ilandmachine_job
    end
    
    @@scheduler.every(@@config["iland_get_template_status_interval"]) do
      puts Time.now.to_s + "get status of Template"
      get_status_of_template
    end
    
    
    @@scheduler.join
  rescue => e
    RAILS_DEFAULT_LOGGER.warn "Exception in schedule: #{e.inspect}"
    exit
  end
end