# Include this in script files to set up rails, a logger, etc.
#
# The logger can be used like this:
#
#  @@logger.info("Some kind of info here.");
#

# Daemonising changes the pwd to /, so we need to switch
# back to RAILS_ROOT.
Dir.chdir(APP_DIR)

# Load our Rails environment.
require File.join('config', 'environment')
@@config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
@@database = YAML.load_file(RAILS_ROOT + "/config/database.yml")
@@pk = @@config["ec2_bin_path"] + @@config["pk"]
@@cert = @@config["ec2_bin_path"] + @@config["cert"]

@@logger = Logger.new(STDOUT)
@@logger.formatter = # noinspection RubyUnusedLocalVariable
    proc do |severity, datetime, prog_name, msg|
      "#{datetime}: #{msg}\n"
    end


