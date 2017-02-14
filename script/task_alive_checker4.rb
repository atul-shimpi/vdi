# used to recover the schedule4
require 'rubygems'
require 'yaml'

RAILS_ROOT = File.join(File.dirname(File.expand_path(__FILE__)), '..')
# this task is supposed to check the tasks every 10 mins. 
# If the task is not running, restart the application  
@@config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
@@schedule4_name = @@config["task_checker_file"] + "_4"
aFile = File.new(@@schedule4_name,"r")
lastTime = aFile.gets.to_i
   
currentTime = Time.new
now_hour = currentTime.hour
now_min = currentTime.min

nowTime = now_hour * 60 + now_min
if (nowTime >= lastTime && nowTime < (lastTime + 2)) ||
   ((nowTime + 24 * 60) >= lastTime && (nowTime + 24 * 60) < (lastTime + 2))
    puts "The schedule4 works well: " + currentTime.to_s
else
    puts "The schedule4 is dead at: " +  currentTime.to_s
#   Remove the mysql operation since it's has been moved to antoher machine    
#   `/etc/init.d/mysqld restart`
#    `/etc/init.d/httpd restart`
    `/usr/local/bin/ruby /var/www/gdevvdi/script/schedule4.rb stop`
    `/usr/local/bin/ruby /var/www/gdevvdi/script/schedule4.rb start`
end