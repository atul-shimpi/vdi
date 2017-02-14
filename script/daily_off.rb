require 'rubygems'
require 'yaml'

# The ruby task will crash easily. So lots of long interval tasks failed to run in 
# ruby task. This file is supposed to add as system cron, and run it in hourly.
RAILS_ENV = 'production'
RAILS_ROOT = File.join(File.dirname(File.expand_path(__FILE__)), '..')
Dir.chdir(RAILS_ROOT)
require File.join('config', 'environment')

def daily_off_machines
  currentTime = Time.now
  Job.find(:all, :conditions => "state in ('Run') and deploymentway = 'DailyOff'").each do |job|
    begin
      if should_poweroff(job, currentTime)
        job.daily_off
        sleep 5
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  end
end

def should_poweroff(job, currentTime)
#  if job.instancetype_id == 1
#    nSmallActiveJobs = Job.find(:all, :conditions => "state in ('Run', 'PowerOFF') and deploymentway = 'DailyOff' and instancetype_id in(1) and jobs.usage not in ('Release', 'Production', 'Preview')").count
#    nSmallPoweredOFFJobs = Job.find(:all, :conditions => "state in ('PowerOFF') and deploymentway = 'DailyOff' and instancetype_id in(1) and jobs.usage not in ('Release', 'Production', 'Preview')").count
#		
#    #If the m1.small instance jobs with 'DailyOff' that are powered off has reached 1/5 of the total m1.small THEN don't powerOFF any more.
#    if nSmallPoweredOFFJobs >= (nSmallActiveJobs * 4) / 5
#      return
#    end
#  end
  now_hour = currentTime.hour
  now_min = currentTime.min
  now_total = now_hour * 60 + now_min
  min_power_time = job.poweroff_hour * 60 + job.poweroff_min
  max_power_time = min_power_time + 11
  if (now_total >= min_power_time && now_total < max_power_time) ||
     ((now_total + 24 * 60) >= min_power_time && (now_total + 24 * 60) < max_power_time)
    puts "The job is ready to Dailly OFF: " + job.id.to_s
    return true
  else
    return false
  end
end

## Dailly power off the machines
puts Time.now.to_s + " Daily power off"
daily_off_machines