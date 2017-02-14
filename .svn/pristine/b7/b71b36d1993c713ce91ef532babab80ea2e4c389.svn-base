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

def undeploy_cluster
  Runcluster.find(:all, :conditions=> "state = 'actives'").each do |runcluster|
    jobs = Job.find(:all, :conditions=> "runcluster_id = #{runcluster.id}")
    if jobs.size != 0   
     jobs = Job.find(:all, :conditions=> "state not in ('Undeploy','Expired') and runcluster_id = #{runcluster.id}")
      if jobs.size == 0
        runcluster.state = 'history'
        runcluster.save
     end
    end
  end
end

def import_template
  Template.find(:all, :conditions => "state in ('pending') and deleted = 0 and (region != 'iland' or region is null)").each do |template| 
    begin
      command = @@config["ec2_bin_path"] + @@config["get_ami_command"]
      command = command + ' ' +  template.ec2_ami + ' -K ' + @@pk +' -C ' + @@cert + ' --region ' + template.region
      result = Template.createTemplate(command, template)
      if template.state == "available" || template.state == "failed"
        if template.job_id > 0
          job = template.parentjob
          job.state = "Run"
          ec2machine = job.ec2machine
          ec2machine.public_dns = ""
          ec2machine.save
          job.save
        end
        puts "Template: " + template.name + " is " + template.state 
      end      
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  end
end

def get_spot_requests_by_region(region)
  check_spot_requests_command = @@config["ec2_bin_path"] + @@config["check_spot_requests"]
  cmd = check_spot_requests_command + ' -K ' + @@pk + ' -C ' + @@cert + ' --region ' + region
  str = IO.popen(cmd)
  sleep(2)
  lines = Array.new
  i=0
  while line=str.gets
    lines[i] = line
    i = i + 1
  end  
  for spotline in lines
    if !spotline.include?('SPOTINSTANCEREQUEST')
      next
    end
    record = spotline.split(" ")
    spot = ActiveSpot.new
    spot.region = region
    spot.spot_id = record[1]
    if record[4] == 'Windows'
      spot.os= 'Windows'
    else
      spot.os= 'Linux'
    end
    spot.status = record[5]
    shift = 0
    if record[7].start_with?('i-')
      spot.instance_id = record[7]
    else
      shift = -1
    end
    spot.instance_type = record[9 + shift]
    spot.save    
  end
end

def get_all_spot_request
  ActiveRecord::Base.connection.execute("delete from active_spots")
  regions = @@config["regions"].split(",")
  for region in regions
    get_spot_requests_by_region(region.strip)
  end
end

def undeploy_dead_spot
  # Sometimes cancelled spot request will launch a instance, and this 
  # instance will keep running... This method is supposed to undeploy such instances
  dead_spots = ActiveSpot.find(:all, :conditions=>"status='cancelled' and instance_id is not null")
  dead_spots.each do |dead_spot|
    begin
      puts "Find dead instance: " + dead_spot.instance_id.to_s
      undeploy_cmd = @@config["ec2_bin_path"] + @@config["delete_instance_command"] + " -K " + @@pk + " -C " + @@cert
      undeploy_cmd += " --region " + dead_spot.region + " " + dead_spot.instance_id.to_s
      IO.popen(undeploy_cmd)
      sleep 2
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  end
end

puts "Undeploy clusters"
undeploy_cluster
puts "Import templates"
import_template
puts "get all spot requests"
get_all_spot_request
puts "Undeploy dead spots"
undeploy_dead_spot