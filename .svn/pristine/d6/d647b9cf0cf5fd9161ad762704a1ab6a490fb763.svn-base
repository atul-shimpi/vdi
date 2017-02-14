# *********************************************************************************************************************************************
# Creation Timestamp 	: 12/Dec/2014 10:33
# Author		: Atul Shimpi (atul.shimpi@gteamstaff.com)
# Purpose		: Updates instances prices in instance_types
# Parameters		: None
# **********************************************************************************************************************************************
APP_DIR = File.join(File.dirname(File.expand_path(__FILE__)), '..')
require  File.join(APP_DIR, 'script/lib/instance_types')

@@logger.info('Starting to update instances prices')
InstanceTypes.update_prices
@@logger.info("Updating instances prices completed")
