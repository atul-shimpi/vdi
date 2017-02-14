require 'rubygems'
require 'yaml'

# The ruby task will crash easily. So lots of long interval tasks failed to run in
# ruby task. This file is supposed to add as system cron, and run it in hourly.
APP_DIR = File.join(File.dirname(File.expand_path(__FILE__)), '..')
require  File.join(APP_DIR, 'script/lib/setup')

def clean_up_all_dead_ebs
  sql = "select * from active_volumes where status = 'available'"
  dead_ebs = ActiveVolume.find_by_sql(sql)
  if dead_ebs.size() > 0
    dead_ebs.each do |ebs|
      begin
        @@logger.info("Deleting: " + ebs.volume_id + "...")
        cmd = @@config["ec2_bin_path"] + @@config["delete_ebs_volume"] + " -C " + @@cert + " -K " + @@pk + ' --region ' + ebs.region + " " + ebs.volume_id
        @@logger.info("Deleting " + ebs.volume_id + " completed successfully.")
        IO.popen(cmd)
        sleep 2
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
    end
  end
end
clean_up_all_dead_ebs