require 'rubygems'
require 'yaml'

# The ruby task will crash easily. So lots of long interval tasks failed to run in 
# ruby task. This file is supposed to add as system cron, and run it in hourly.
RAILS_ENV = 'production'
RAILS_ROOT = File.join(File.dirname(File.expand_path(__FILE__)), '..')
Dir.chdir(RAILS_ROOT)
require File.join('config', 'environment')
@@config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
@@apipath = @@config["iland_api_jar_path"]
@@configpath = @@config["iland_configuration_path"]

def update_active_ilandmachiens_by_region(region)
  #remove all old code
  begin
    update = @@config["iland_get_all_vm"]
    get_all_instance_cmd = "java -cp #{@@apipath} #{update} #{@@configpath}" + " --request-timeout 30"
    puts "get_all_instance_cmd*****"+get_all_instance_cmd.to_s
    strs = IO.popen(get_all_instance_cmd)
    sleep(1)
    line=strs.gets
    records = line.split(",")
    records.each do |record|
      activeilandmachine = ActiveIlandmachine.new()
      vmmessages = record.split("#")
      activeilandmachine.vapp_href = vmmessages[0]
      activeilandmachine.instance_id = vmmessages[1]
      activeilandmachine.private_dns = vmmessages[2]
      activeilandmachine.public_dns = Job.get_iland_public_ip(vmmessages[2])
      activeilandmachine.region = "iland"
      if vmmessages[3].include?("CentOS")
        activeilandmachine.os = "Linux"
      else
        activeilandmachine.os = "windows"
      end
      if vmmessages[4] == "8"
        activeilandmachine.state = "stopped"
      elsif vmmessages[4] == "4"
        activeilandmachine.state = "start"
      else
        activeilandmachine.state = "running"
      end
      memorysize = Integer(vmmessages[5])
      cpusize = Integer(vmmessages[6])
      puts "memorysize:"+memorysize.to_s
      puts "cpusize:"+cpusize.to_s
      instancetypename = Instancetype.find(:first,:conditions => "memorysize = #{memorysize} and cpusize = #{cpusize}").name
      activeilandmachine.instance_type = instancetypename
      activeilandmachinelist = ActiveIlandmachine.find(:all, :conditions => "region = 'iland'")
      activeilandmachinelist.each do |activemachine|
          ActiveRecord::Base.connection.execute("delete from active_ilandmachines where instance_id = '#{vmmessages[1]}'")
      end
      activeilandmachine.save
    end
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
  end   
  
end
def update_all_ilandmachines
  #ActiveRecord::Base.connection.execute("delete from active_machines")
  regions = @@config["iland_region"].split(",")
  for region in regions
    update_active_ilandmachiens_by_region(region.strip)
  end
end
update_all_ilandmachines
ScheduleTask.recover_dead_iland_deployment