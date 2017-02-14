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

def update_active_machiens_by_region(region)
  #remove all old code
  begin
    get_all_instance_cmd = @@config["ec2_bin_path"] + @@config["get_instance_command"] + " -C " + @@cert + " -K " + @@pk + ' --region ' + region + " --request-timeout 30"
    strs = IO.popen(get_all_instance_cmd)
    sleep(1)
    i = 0
    lines = Array.new
    while line=strs.gets
          lines[i] = line
          i = i + 1
    end
    if lines.length < 3
      puts "Get machines failed, retry it"
      puts Time.now.to_s
      strs = IO.popen(get_all_instance_cmd)
      sleep(3)
      i = 0
      lines = Array.new
      while line=strs.gets
          lines[i] = line
          i = i + 1
      end     
    end
    if lines.length >= 3
      ActiveRecord::Base.connection.execute("delete from active_machines where region = '#{region}'")
      i = 0
      while i < lines.length - 1
        if lines[i].include?("RESERVATION") 
          ## parse the resevation line
          record = lines[i].split("\x09")
          machine = ActiveMachine.new()
          machine.security_group = record[3].strip
          i = i + 1
          if lines[i].include?("INSTANCE") 
            record = lines[i].split("\x09") 
            machine.instance_id = record[1]
            machine.ami_id = record[2]
            machine.public_dns = record[3]
            machine.public_ip = record[16]
            machine.private_ip = record[17]
            if !machine.public_dns.include?('ec2-')
              machine.public_dns = machine.public_ip
            end
            machine.private_dns = record[4]
            machine.state = record[5]
            machine.key_pair = record[6] 
            machine.instance_type = record[9]
            machine.launch_time = record[10]
            machine.zone = record[11]
            machine.region = region
            machine.os = record[14]
            if machine.os != 'windows'
              machine.os = 'linux'
            end
            machine.block_devices = record[20]
            machine.sg_id = record[28]
            if machine.security_group.blank?
              machine.security_group = machine.sg_id
            end
            machine.save
          end
        end
        i = i + 1
      end
    end
  rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
  end   
end
def update_all_machines
  #ActiveRecord::Base.connection.execute("delete from active_machines")
  regions = @@config["regions"].split(",")
  for region in regions
      update_active_machiens_by_region(region.strip)
  end
end
update_all_machines
ScheduleTask.recover_dead_deployment