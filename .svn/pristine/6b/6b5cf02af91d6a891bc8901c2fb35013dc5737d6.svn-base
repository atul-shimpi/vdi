#!/usr/bin/env ruby
# This script should be used when there is only 1 machine in the VDI server cluster (or for a development instance)
require 'rubygems'
require 'popen4'
require 'daemons'
require 'thread'
require 'time'
APP_DIR = File.join(File.dirname(File.expand_path(__FILE__)), '..')
require File.join(APP_DIR, 'script/lib/setup')

@@logger.info("RAILS ENV = #{RAILS_ENV}")
@@deploy_count = 0
@@recover_count = 0

def create_instances_task
  @@deploy_count = @@deploy_count + 1
  @@logger.info("Deploy count: " + @@deploy_count.to_s)

  if @@deploy_count >= 2
    @@logger.info("Too many deployment processes running, skip it")
    @@deploy_count = @@deploy_count - 1
    return
  end

  if ScheduleTask.jobs_count() >= 8
    @@deploy_count = @@deploy_count - 1
    #Do nothing if the deploy load is high
    return
  end

  skip_count = 0
  ScheduleTask.each_job("('Pending', 'Deploying')") do |index, job, pending_jobs_count|
    if ((job.state == "Deploying"))
      if pending_jobs_count > 0
        next
      else
        if skip_count == (@@recover_count + @@recover_count) || pending_jobs_count <= (@@recover_count + @@recover_count)
          skip_count = 0
          @@logger.info("Deployiing job #{job.id}...")
          ScheduleTask.deploy_job(job)
        else
          skip_count = skip_count + 1
          @@logger.info("Skipping deployment: #{job.id}")
          next
        end #skip_count
      end #(state == Deployment)
    end # ScheduleTask.each_job
    ScheduleTask.deploy_job(job)
  end
  @@deploy_count = @@deploy_count - 1
end

# Do not make this process synchronized to avoid the dead task
def cleanup_dead_deployment
  @@recover_count = @@recover_count + 1
  @@logger.info("Recover count: " + @@recover_count.to_s);
  if @@recover_count >= 2
    @@logger.info("To many recover process running, skip it");
    @@recover_count = @@recover_count - 1
    return
  end
  ScheduleTask.cleanup_dead_deployment(11, 0)
  @@recover_count = @@recover_count - 1
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
    ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new(File.join(APP_DIR, 'log/schedule_single.log'))

    # Initialise the OpenWFE scheduler object.
    require 'rufus/scheduler'
    @@scheduler = Rufus::Scheduler.start_new

    # This is necessary to work on Windows
    ActiveRecord::Base.connection.reconnect! unless ActiveRecord::Base.connection.active?
    @@logger.info("Pending Count: #{ScheduleTask.jobs_count("('Pending')").to_s}")

    # Now assign jobs to the scheduler (see API). For example:

    # update ec2machine's public_dns
    @@scheduler.every(@@config["update_dns_interval"]) do
      @@logger.info("Updating DNS...")
      ScheduleTask.update_ec2machine_public_dns
      @@logger.info("Updating DNS completed.");
    end

    #delete job ec2machine,update securitytype
    @@scheduler.every(@@config["delete_expire_job_interval"]) do
      @@logger.info("Deleting expired jobs...")
      ScheduleTask.delete_job_ec2machine_and_update_security_type
      @@logger.info("Deleting expired jobs completed.")
    end

    #delete securitygroup
    @@scheduler.every(@@config["delete_securitygroup_interval"]) do
      @@logger.info("Deleting Security Groups...")
      ScheduleTask.delete_security_type
      @@logger.info("Deleting Security Groups completed.")
    end

    #check spot requests
    @@scheduler.every(@@config["check_spot_requests_time"]) do
      @@logger.info("Checking spot requests...")
      regions = @@config["regions"].split(",")
      for region in regions
        ScheduleTask.check_spot_requests(region.strip)
      end
      @@logger.info("Checking spot requests completed.")
    end

    #Create instances
    @@scheduler.every("45s") do
      @@logger.info("Creating instances...")
      create_instances_task
      @@logger.info("Creating instances completed.")
    end


    #Cleanup dead deployments
    @@scheduler.every("42s") do
      @@logger.info("Cleanup dead deployments...")
      cleanup_dead_deployment
      @@logger.info("Cleanup dead deployments completed.")
    end

    #Send email
    @@scheduler.every(@@config["send_mail_interval"].to_s + "m") do
      @@logger.info("Sending mail...")
      ScheduleTask.send_mail
      @@logger.info("Sending mail completed.")
    end

    # Send warning to admin while there are too many pending jobs, which means vdi is hung...
    @@scheduler.every("100s") do
      @@logger.info("Sending pending job warnings...")
      ScheduleTask.pending_job_warning
      @@logger.info("Sending pending job warnings completed.")
    end

    # Update volume status
    @@scheduler.every("25s") do
      @@logger.info("Updating volumes info...")
      ScheduleTask.check_volumes
      @@logger.info("Updating volumes info completed.")
    end

    # Update snapshot status
    @@scheduler.every("125s") do
      @@logger.info("Updating snapshot info...")
      ScheduleTask.check_snapshots
      @@logger.info("Updating snapshot info completed.")
    end

    # Check demo jobs
    @@scheduler.every("5m") do
      @@logger.info("Updating demo jobs...")
      ScheduleTask.check_demo_jobs
      @@logger.info("Updating demo jobs completed.")
    end
    @@scheduler.every("30s") do
      @@logger.info("Assign VPC elastic IPs...")
      ScheduleTask.assign_vpc_elasticip
      @@logger.info("Assign VPC elastic IPs completed.")
    end
    @@scheduler.every("333s") do
      @@logger.info("Cleaning up VPC_elastic IPs...")
      ScheduleTask.cleanup_vpc_elasticip
      @@logger.info("Cleaning up VPC_elastic IPs complete.")
    end

    # Tell the scheduler to perform these jobs until the
    # process is stopped.
    @@scheduler.join
  rescue => e
    @@logger.warn "Exception in schedule: #{e.inspect}"
    puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
    exit
  end
end
