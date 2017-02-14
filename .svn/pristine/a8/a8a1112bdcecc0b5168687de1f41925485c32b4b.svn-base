require 'rubygems'
require 'yaml'
require 'mysql'

# The ruby task will crash easily. So lots of long interval tasks failed to run in
# ruby task. This file is supposed to add as system cron, and run it in hourly.
RAILS_ENV = 'production'
RAILS_ROOT = File.join(File.dirname(File.expand_path(__FILE__)), '..')
Dir.chdir(RAILS_ROOT)
require File.join('config', 'environment')

def idle_off_machine(instanceid)
  machine = Ec2machine.find(:last, :conditions=>"instance_id = '#{instanceid}'")
  if machine
    job = Job.find(:last, :conditions=> "ec2machine_id = #{machine.id}")    
    if job.state == "Run" && (job.usage == 'VDIBuild' || job.usage == 'Configuration')
      puts "Idle Off " + job.id.to_s
      puts job.usage
      job.idle_off()
      sleep 3
    else
      puts "Skip job: " + job.id.to_s
      puts job.usage
    end    
  end
end

def idle_off_machines
  mysql_registry = Mysql.init()
  mysql_registry.connect('monitor.gdev.com','kinson','iPheiP6X')
  mysql_registry.select_db('registry')
  time = Time.now  - 9*60*60
  end_time = time.strftime("%Y-%m-%d %H:%M:%S")
  sql = "SELECT * from monitoring_cpu where ts > '#{end_time}' order by instance"
  results = mysql_registry.query(sql)
  mysql_registry.close()

  instance = ""
  idle_count = 0
  busy_count = 0
  results.each do |r|
    begin
      #puts r[0] + " " + r[2]
      if r[0] != instance
        #puts instance + " " + idle_count.to_s + " " + busy_count.to_s
        if idle_count > 24 && busy_count == 0
          idle_off_machine(instance)
        end
        instance = r[0]
        idle_count = 0
        busy_count = 0
      end
      if r[2].to_i < 2
        idle_count = idle_count + 1
      else
        busy_count = busy_count + 1
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  end
end

## power off the idle machines
puts Time.now.to_s + " Idle power off"
idle_off_machines
