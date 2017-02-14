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

def delete_job_ec2machine_and_update_security_type
  ScheduleTask.delete_job_ec2machine_and_update_security_type
end

#delete securitytype
def delete_security_type
  ScheduleTask.delete_security_type
end

puts "Clean expired machines"
delete_job_ec2machine_and_update_security_type
puts "clean deleted security groups"
delete_security_type