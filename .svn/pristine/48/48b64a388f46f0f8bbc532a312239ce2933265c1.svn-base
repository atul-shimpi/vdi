require 'date'

MINUTES_IN_1_HOUR = 60
HOURS_IN_1_DAY = 24

class Ec2machine < ActiveRecord::Base
  has_many :jobs
  
  def is_publicdns_valid
    # TODO: the ip checker should be optimized
    ipnums = public_dns.split('.')    
    if public_dns && (public_dns.include?('ec2') || ipnums.size >=4)
      return true
    else 
      return false
    end
  end
  
  def self.is_valid_ip(ip)
    # TODO: the ip checker should be optimized    
    ipnums = ip.split('.')
    if ipnums.size ==4
      return true
    else 
      return false
    end
  end

  def running_for_hour?
    running_min >= MINUTES_IN_1_HOUR
  end

  # Return no of minutes for which instance is running
  def running_min
    # local_launch_time can be nil since this is updated by cron job
    if local_launch_time.nil?
      @@logger.info("Launch Time not updated for instance #{instance_id} (EC2Machine ID: #{id}")
      return -1
    end

    inst_launch_time = DateTime.new(
                                     local_launch_time.year,
                                     local_launch_time.month,
                                     local_launch_time.day,
                                     local_launch_time.hour,
                                     local_launch_time.min,
                                     local_launch_time.sec
                                   )

    # get rational (datetime terminology) difference
   curr_time = DateTime.new(
                              DateTime.now.year,
                              DateTime.now.month,
                              DateTime.now.day,
                              DateTime.now.hour,
                              DateTime.now.min,
                              DateTime.now.sec
                            )

    time_diff = (curr_time - inst_launch_time).to_f
    # Convert rational difference to minutes
    time_diff = (time_diff * HOURS_IN_1_DAY * MINUTES_IN_1_HOUR).to_i
    @@logger.info("Instance : #{instance_id} running for #{time_diff} minutes (Now : #{curr_time.to_s}, Launch Time : #{inst_launch_time.to_s})")
 
    time_diff
  end
end
