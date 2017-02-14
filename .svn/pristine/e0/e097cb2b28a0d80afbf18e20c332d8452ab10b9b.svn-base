class Configuration < ActiveRecord::Base
    has_many :jobs
    belongs_to :template
    belongs_to :template_mapping
    belongs_to :user
    belongs_to :securitygroup
    belongs_to :group
    belongs_to :securitytype
    belongs_to :instancetype
    belongs_to :updater,:class_name => 'User', :foreign_key => :update_by
    has_and_belongs_to_many :clusterconfigurations
    has_and_belongs_to_many :securities
    
    def self.generate_telnet_commands(job, configuration)
      if configuration.commands != nil && configuration. commands.strip != ""
          telnetcommands = configuration.commands.split("\r\n")
          telnetcommands.each{|command|
              runtelnetcommand = Runcommand.new
              runtelnetcommand.job_id = job.id
              runtelnetcommand.commands = command
              runtelnetcommand.cmd_path = configuration.cmd_path
              runtelnetcommand.state = "Pendding"
              runtelnetcommand.cmd_type = "telnet"
              runtelnetcommand.created_at = Time.now
              runtelnetcommand.updated_at = Time.now
              runtelnetcommand.save
          }
      end      
  end
  # Add the userdata to commands so that it will show in configuration page. 
  # Note user data commands will not be exectuted by the VDI server
  def self.add_userdata_as_commands(job, configuration)
    if configuration.init_commands != nil && configuration.init_commands.strip != ""
      init_commands = configuration.init_commands.split("\r\n")
      init_commands.each{|command|
        runtelnetcommand = Runcommand.new
        runtelnetcommand.job_id = job.id
        runtelnetcommand.commands = command
        runtelnetcommand.cmd_path = configuration.cmd_path
        runtelnetcommand.state = "RunByVDIClient"
        runtelnetcommand.cmd_type = "userdata"
        runtelnetcommand.created_at = Time.now
        runtelnetcommand.updated_at = Time.now
        runtelnetcommand.save
      }
    end      
  end
  
  def replace_index(num)
     column_names = attributes.keys
     temp_attributes = {}
     column_names.each do |column_name|
       column_value = attributes[column_name]
       if column_value.class.to_s == "String" && column_value.include?('$index') 
         temp_attributes[column_name] = column_value.gsub('$index', num)
       end
     end
     update_attributes(temp_attributes)
  end
  def is_vpc
    if deploymentway == 'vpc-default' || deploymentway == 'vpc-dedicated'
      return true
    else
      return false
    end
  end
  
  def can_access(user)
    if user.is_external && self.user_id != user.id
      return false
    end
    return true
  end
end