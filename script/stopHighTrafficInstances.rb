# *********************************************************************************************************************************************
# Creation Timestamp 	: 12/Dec/2014 02:11
# Author		   : Atul Shimpi (atul.shimpi@gteamstaff.com)
# Purpose		   : Power Off's EC2 instances based on Avg data send out for a duration
# Parameters   : None
# **********************************************************************************************************************************************
APP_DIR = File.join(File.dirname(File.expand_path(__FILE__)), '..')
require  File.join(APP_DIR, 'script/lib/monitor_instances')

@@logger.info('stopHighTrafficInstances.rb started')
mon = MonitorInstances.new
mon.power_off_by_data_send_out
@@logger.info('stopHighTrafficInstances.rb ended')
