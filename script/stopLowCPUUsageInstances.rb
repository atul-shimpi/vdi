# *********************************************************************************************************************************************
# Creation Timestamp 	: 12/Dec/2014 10:33
# Author		: Atul Shimpi (atul.shimpi@gteamstaff.com)
# Purpose		: Allows to Power Off's EC2 instances based on CPU Usage.
# Parameters		: None
# **********************************************************************************************************************************************
APP_DIR = File.join(File.dirname(File.expand_path(__FILE__)), '..')
require  File.join(APP_DIR, 'script/lib/monitor_instances')

@@logger.info('stopLowCPUUsageInstances.rb started')
mon = MonitorInstances.new
mon.power_off_by_cpu_usage(5, 3600)
@@logger.info("stopLowCPUUsageInstances.rb ended")
