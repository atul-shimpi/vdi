class Job < ActiveRecord::Base
  belongs_to :user
  belongs_to :securitygroup
  belongs_to :template
  belongs_to :ec2machine
  belongs_to :ilandmachine
  belongs_to :group
  belongs_to :subnet
  belongs_to :runcluster  
  belongs_to :instancetype
  belongs_to :securitytype
  belongs_to :configuration
  has_many :command
  has_many :newcommand
  has_many :extend_lease_logs, :class_name => 'ExtendLeaseLog', :foreign_key => :job_id
  has_and_belongs_to_many :securities
  belongs_to :support, :class_name => "User" , :foreign_key => "support_id"
  
  validates_presence_of :name,:instancetype,:securitygroup
  
  STATUS = {
    :active => ['Run', 'Pending', 'Open', 'Deploying', 'PowerOFF', 'Capturing'],
    :disabled => ['Build Fail', 'Undeploy', 'Expired', 'Spot Fail']
  }
  @@invalid_password = "'QEL9MoMS', 'alterpoint', 'vmlogix', 'Changeme!', 'zen2oidh'"
  
  def self.get_invalid_password
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    return  config["invalid_password"]
  end
  
  def self.invalid_password_string
    invalid_passwords = Job.get_invalid_password
    invalid_passwords = invalid_passwords.gsub(",", "','")
    invalid_passwords = "'" + invalid_passwords + "'"
    return invalid_passwords
  end
  def allow_open_for_all(user)
    return true if user.is_admin
    return false if self.template.is_unsecure == 1
    return false if Job.get_invalid_password.include? get_password

    return true
  end
  
  def get_password
    job_password = self.machinepassword
    if job_password.blank?
      job_password = self.template.password
    end
    return job_password
  end
  
  def can_read_job(user)
    return user.id == self.user_id || user.is_admin || 
     (self.rpermission.to_i == 1 && user.is_in_sharegroup(self.group)) ||
     (self.permission.to_i == 1 && user.is_in_sharegroup(self.group)) ||
     (user.is_sys_admin && support_id == user.id) || (Group.is_manager(user, self.user) && !(self.user.is_admin)) ||
    (user.is_testbreak_team && ['Configuration', 'VDIBuild'].include?(self.usage))
    
  end
  
  def can_write_job(user)
    return user.id == self.user_id || user.is_admin || 
     (self.permission.to_i == 1 && user.is_in_sharegroup(self.group)) ||
     (user.is_sys_admin && support_id == user.id) || (Group.is_manager(user, self.user) && !(self.user.is_admin)) ||
     (user.is_testbreak_team && ['Configuration', 'VDIBuild'].include?(self.usage))
  end
  
  def can_extend_lease?
    return true if ["DailyOff","Spot"].include?(self.deploymentway)
    false
  end
  
  def self.is_power_enalbed(job)
    if !(job.template.is_ebs) && job.region != "iland"
      return false
    end
    if job.ec2machine
      if job.ec2machine.lifecycle != "Spot"
        return true
      end
    end
    if job.ilandmachine    
      return true
    end
    return false
  end
  
  def self.is_operation_enabled(job)
    return !(job.state == "Pending" || job.state == "Undeploy" || job.state == "Deploying" || job.state == "Open" || job.state == "Expired" || job.state == "Capturing")
  end
  
  def addcommand(job,securities,instancetype, userdate)
    id = job.id
    ami_name = job.ami_name
    securitytype_name = job.securitytype_name
    deploymentway = job.deploymentway
    max_price = job.max_price
    template = job.template
    # Save security to db
    securitytype = Securitytype.new
    securitytype.name = job.securitytype_name
    securitytype.state = job.state
    securitytype.region = job.template.region
    securitytype.save
    
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    pk = config["ec2_bin_path"] + config["pk"]
    cert = config["ec2_bin_path"] + config["cert"]
    securitytypecommand = config["ec2_bin_path"] + config["add_group"]
    securitytypecmd = securitytypecommand + ' ' +  securitytype_name + ' -d' + ' "' + securitytype_name + ' Web Servers"' +
                          ' -K ' + pk +' -C ' + cert + ' --region ' + template.region
    if job.is_vpc
      securitytypecmd = securitytypecmd + " -c " + job.subnet.vpc_id
    end
    cmd = Cmd.new()
    cmd.job_id = id
    cmd.command = securitytypecmd
    cmd.state = "Pending"
    cmd.job_type = "C"
    cmd.created_at = Time.now
    cmd.updated_at = Time.now
    cmd.description = config["create_security_group_description"] + " " + securitytype_name
    cmd.save
    
    securityportcommand = config["ec2_bin_path"] + config["change_group_port"]
    ec2_account_id = config["ec2_account_id"].to_s
    securities.each{|security|
      securityport = Security.find(security.security_id)
      if securityport.port_from.to_s == "3389" && !job.template.is_virus_secure
        if !["Production", "Preview", "Demo"].include?(job.usage)
          #skip 3389 port if the password is not secure
          next
        end
      end
      sourcetype = securityport.source.scan(/\d+.\d+.\d+.\d+\/\d+/)
      securityportcmd = ""
      if sourcetype.size == 0
        securityportcmd = securityportcommand + ' -K ' + pk +' -C ' + cert +
                        ' --region ' + template.region + ' -u ' + ec2_account_id + " -o " + securityport.source
      else
        if securityport.protocol == "icmp"
          securityportcmd = securityportcommand + " -P " + securityport.protocol + " -t -1:-1"  + " -s " + securityport.source + 
                          ' -K ' + pk +' -C ' + cert + ' --region ' + template.region
        else
          securityportcmd = securityportcommand + " -P " + securityport.protocol + " -p " + securityport.port_from.to_s + "-" + securityport.port_to.to_s + " -s " + securityport.source + 
                          ' -K ' + pk +' -C ' + cert + ' --region ' + template.region
        end
      end
      if job.is_vpc
        securityportcmd = securityportcmd + " $securitygroup_id"
      else
        securityportcmd = securityportcmd + " " + securitytype_name
      end
      cmd = Cmd.new
      cmd.job_id = id
      cmd.command = securityportcmd
      cmd.state = "Pending"
      cmd.job_type = "C"
      cmd.created_at = Time.now
      cmd.updated_at = Time.now
      cmd.description = config["add_security_group_protocol_description"] + " " + securityport.protocol + " " + config["add_security_group_port_description"] + " " + securityport.port_from.to_s + "-" + securityport.port_to.to_s + " " + config["add_security_group_source_description"] + " " + securityport.source
      cmd.save
    }
    
    cmd = Cmd.new
    cmd.job_id = id
    userdataParam = ""
    if userdate != nil && userdate.strip != ""
      userdataFilePath = File.join(config["init_cmd_path"], job.id.to_s)
      userdataFile = File.new(userdataFilePath,"w")
      userdataFile.puts(userdate);
      userdataFile.close
      userdataParam = " -f " +  userdataFilePath     
    end
    if deploymentway == "Spot"
      instancecommand = config["ec2_bin_path"] + config["create_spot_instance"]
      instancecmd = instancecommand + ' ' +  ami_name + ' -g ' + securitytype_name + 
      ' -k ' + config["key-pair"] + ' -p ' + max_price.to_s + ' --instance-type ' + instancetype +  ' -K ' + pk +' -C ' + cert + ' --region ' + template.region
      cmd.description = config["create_spot_instance_description"]
    else
      instancecommand = config["ec2_bin_path"] + config["create_instance"]
      instancecmd = instancecommand + ' ' +  ami_name + ' -k ' + config["key-pair"] + ' --instance-type ' + instancetype +  ' -K ' + pk +' -C ' + cert + ' --region ' + template.region + userdataParam
      az = pick_az
      if !az.blank?
        instancecmd += " -z " + az
      end
      cmd.description = config["create_normal_instance_description"]
      if job.is_vpc
        instancecmd = instancecmd + " -s " + job.subnet.subnet_id +  ' -g $securitygroup_id'
        if job.deploymentway == "vpc-dedicated" 
          instancecmd = instancecmd + " --tenancy " + "dedicated"
        else
          instancecmd = instancecmd + " --tenancy " + "default"
        end
      else
        instancecmd = instancecmd + ' -g ' + securitytype_name
      end
    end
    cmd.created_at = Time.now
    cmd.updated_at = Time.now
    cmd.command = instancecmd
    cmd.state = "Pending"
    cmd.job_type = "C"
    cmd.save
  end
  
  def addcommandiland(job,instancetype, userdate)
    cmd = Cmd.new
    id = job.id
    name = job.name
    iland_template = job.template
    #we use ec2_ami field to iland templates
    template_iland = iland_template.ec2_ami
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    apipath = config["iland_api_jar_path"]
    configpath = config["iland_configuration_path"]
    jobcommand = config["iland_new_vapp"]
    instancecmd = "java -cp #{apipath} #{jobcommand} #{configpath} #{template_iland} \"vdijob_#{id.to_s}_#{name}\""
    cmd.job_id = id
    cmd.created_at = Time.now
    cmd.updated_at = Time.now
    cmd.command = instancecmd
    cmd.state = "Pending"
    cmd.job_type = "C"
    cmd.description = "New Vapp"
    cmd.save
    return cmd
  end
  
  def self.write_user_data(job) 
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    if !job.init_commands.blank?
      userdate = job.init_commands
    else
      configuration = job.configuration
      if configuration.nil?
        return
      end
      userdate = configuration.init_commands
    end
    if userdate != nil && userdate.strip != ""
      userdataFilePath = File.join(config["init_cmd_path"], job.id.to_s)
      userdataFile = File.new(userdataFilePath,"w")
      userdataFile.puts(userdate);
      userdataFile.close
      userdataParam = " -f " +  userdataFilePath     
    end    
  end
  def deletejob(job)
    if job.state == "Run" || job.state == "PowerOFF"
      config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
      pk = config["ec2_bin_path"] + config["pk"]
      cert = config["ec2_bin_path"] + config["cert"]
      if job.ec2machine_id != nil
        ec2machine = Ec2machine.find(job.ec2machine_id)
        delete_instance_command = config["ec2_bin_path"] + config["delete_instance_command"]
        cmdLine = delete_instance_command + ' ' +  ec2machine.instance_id.to_s + ' -K ' + pk +' -C ' + cert + ' --region ' + job.template.region
        
        cmd = Cmd.new()
        cmd.job_id = job.id
        cmd.command = cmdLine
        cmd.state = "Pending"
        cmd.job_type = "U"
        cmd.created_at = Time.now
        cmd.updated_at = Time.now
        cmd.description = "Undeploy"
        
        POpen4.popen4(cmdLine) do |stdout, stderr, stdin, pid|
          status_err = stderr.read.strip
          if status_err != nil && status_err != ""
            cmd.state = "Fail"
            cmd.error_log = status_err
          else 
            cmd.state = "Success"
          end
        end
        cmd.save
        ec2machine.status = "Undeployed"
        ec2machine.save
      end
      if job.ilandmachine_id != nil
        if job.state == "Run"
          Cmd.stop_machine_iland(job, job.ilandmachine)
        end
        ilandmachine = Ilandmachine.find(job.ilandmachine_id)
        vapp_id = ilandmachine.vapp_id
        apipath = config["iland_api_jar_path"]
        configpath = config["iland_configuration_path"]
        jobcommand = config["iland_delete_vapp"]
        deletecommand = "java -cp #{apipath} #{jobcommand} #{configpath} #{vapp_id}"
        
        cmd = Cmd.new()
        cmd.job_id = job.id
        cmd.command = deletecommand
        cmd.state = "Pending"
        cmd.job_type = "U"
        cmd.created_at = Time.now
        cmd.updated_at = Time.now
        cmd.description = "Undeploy"
        cmd.save
        ilandmachine.status = "Undeployed"
        ilandmachine.save
        job.is_busy = 1
        job.save
      end
      
      if job.securitytype_name != nil
        securitytypes = Securitytype.find(:all, :conditions => ['name = ?', job.securitytype_name])
        securitytypes.each {|securitytype|
          securitytype.state = "shut_down"
          securitytype.save
        }
      end
    end
    job.state = "Undeploy"
    job.save
  end
  
  def self.deployjobfromconf(job,configuration,user)    
    job.name = configuration.name
    job.description = configuration.description
    if configuration.template_mapping_id
      template = configuration.template_mapping.template
    else
      template = configuration.template
    end
    job.region=template.region
    job.template_id = template.id
    job.user_id = user.id
    job.rpermission = configuration.rpermission
    job.permission = configuration.permission
    job.lease_time = Time.now + configuration.lease_time*24*60*60
    #Force configuration to 1 day if the lease time was not backend hardcoded
    #if configuration.lease_time <= 3
    #  job.lease_time = Time.now + 24*60*60
    #end
    job.usage = 'Configuration'
    job.ami_name = template.ec2_ami
    job.group_id = configuration.group_id
    job.instancetype_id = configuration.instancetype_id
    job.securitygroup_id = configuration.securitygroup_id
    job.configuration_id = configuration.id
    job.subnet_id = configuration.subnet_id
    job.securitytype_name = ""
    job.state = "Pending"
    job.save
    job.securitytype_name = user.name.gsub(/\W/,'') + "_" + Job.find(:last).id.to_s + "_1"
    configuration.init_commands = configuration.init_commands.gsub(/\$job_id/, job.id.to_s)
    job.created_at = Time.now
    job.updated_at = Time.now
    job.deploymentway = configuration.deploymentway
    platform = template.platform
    instancetype = Instancetype.find(configuration.instancetype_id).name
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    no_spot = config["no_spot_instances"]
    if job.deploymentway == "Spot"
      # Dev pay instances do not support spot deployment
      # no spot instance should not go with spot
      if template.dev_pay == 1 || (no_spot != nil && no_spot.include?(instancetype))
        job.deploymentway = "normal"
      else    
        max_price = ""
        if platform == "Windows"
          max_price = Instancetype.find_by_name(instancetype).windows_maxprice
        else
          max_price = Instancetype.find_by_name(instancetype).linux_maxprice
        end
      end
    end  
    job.max_price = max_price
    job.poweroff_hour = configuration.poweroff_hour
    job.poweroff_min = configuration.poweroff_min
    job.telnet_service = "stop"
    if template.telnet_enabled == 0
      job.telnet_service = "disabled"
    end
    if job.securitygroup_id == nil 
      job.securitygroup_id = 1
    end
    job.save
    if template.region != "iland"
      securitygroup = Securitygroup.find(job.securitygroup_id)
      securities = securitygroup.securities
      job.addcommand(job, securities,instancetype, configuration.init_commands)
    else
      cmd = job.addcommandiland(job,instancetype, configuration.init_commands)
      state = Cmd.run_newvapp_command_for_iland(cmd)
      #new ilandmachine
      if state != "Fail"
        ilandmachine = Ilandmachine.new
        ilandmachine.vapp_id = state
        ilandmachine.platform = template.platform
        ilandmachine.lifecycle = job.deploymentway
        ilandmachine.status = "Deploying"
        getilandmachine = ilandmachine.save
        if getilandmachine
          job.ilandmachine_id = ilandmachine.id
          job.state = "Pending"
          job.save
        end
      end
    end
  end   
  
  def is_vpc
    if deploymentway == 'vpc-default' || deploymentway == 'vpc-dedicated'
      return true
    else
      return false
    end
  end
  
  def self.get_unsecure_jobs(user)
    sql = "select j.* from
             (select * from jobs where user_id = #{user.id} and state in ('Run')) as j
           left join templates t on j.template_id = t.id
           where (j.machinepassword is null or j.machinepassword in (#{Job.invalid_password_string}))and t.password in (#{Job.invalid_password_string})"
    return Job.find_by_sql(sql);    
  end 
  
  def self.get_running_job_by_instanceid(instanceid)
    ec2machines = Ec2machine.find(:all, :conditions=>"instance_id = '#{instanceid}'")
    
    ec2machines.each do |e|
      job = Job.find_by_ec2machine_id(e.id)
      if !job.nil? && job.state == "Run"
        return job
      end
    end
    return nil
  end
  def self.get_iland_public_ip(private_dns)
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    mask = config["mask"]
    publicDns = config["public_dns"]
    privatednsarray = private_dns.split(".")
    maskarray = mask.split(".")
    publicdnsarray = publicDns.split(".")
    rightpublicdns = ""
    i = 0
    while i<privatednsarray.length do
      rightpublicdns = rightpublicdns + ((Integer(privatednsarray[i])&(Integer(maskarray[i])^255))|Integer(publicdnsarray[i])).to_s
      if i<3
        rightpublicdns=rightpublicdns+"."
      end
      i +=1
    end
    return rightpublicdns
  end
  
  def power_off
    if Job.is_power_enalbed(self)
      if self.region!="iland"
        cmd = Cmd.stop_machine(self, self.ec2machine)
        state = Cmd.run_power_command(cmd)
        if state == "Success"
          self.state = "PowerOFF"
          self.save
        end
      else 
        cmd = Cmd.stop_machine_iland(self, self.ilandmachine)
        state = Cmd.run_power_command_iland(cmd)
        if state == "Success"
          self.state = "PowerOFF"
          self.is_busy = 1
          self.save
        end
      end      
    end 
  end
  def daily_off
    if Job.is_power_enalbed(self)
      if self.region!="iland"
        cmd = Cmd.daily_off_machine(self, self.ec2machine)
        state = Cmd.run_power_command(cmd)
        if state == "Success"
          self.state = "PowerOFF"
          self.save
        end
      else
        cmd = Cmd.daily_off_machine_iland(self, self.ilandmachine)
        state = Cmd.run_power_command_iland(cmd)
        if state == "Success"
          self.state = "PowerOFF"
          self.is_busy = 1
          self.save
        end
      end      
    end   
  end

  def high_network_off
    if Job.is_power_enalbed(self)
      if self.region!="iland"
        cmd = Cmd.high_network_off(self, self.ec2machine)
        state = Cmd.run_power_command(cmd)
        if state == "Success"
          self.state = "PowerOFF"
          self.save
        end
      else
        # Unsupported, currently.
      end
    end
  end

  def low_cpu_off
    if Job.is_power_enalbed(self)
      if self.region!="iland"
        cmd = Cmd.low_cpu_off(self, self.ec2machine)
        state = Cmd.run_power_command(cmd)
        if state == "Success"
          self.state = "PowerOFF"
          self.save
        end
      else
        # Unsupported, currently.
      end
    end
  end

  def idle_off
    if Job.is_power_enalbed(self)
      if self.region!="iland"
        cmd = Cmd.idle_off_machine(self, self.ec2machine)
        state = Cmd.run_power_command(cmd)
        if state == "Success"
          self.state = "PowerOFF"
          self.save
        end
      end
    end   
  end
  
  def power_on
    if Job.is_power_enalbed(self)
      if self.region!="iland"
        cmd = Cmd.start_machine(self, self.ec2machine)
        state = Cmd.run_power_command(cmd)
        if state == "Success"
          self.state = "Run"
          self.save
          ec2machine = self.ec2machine
          ec2machine.public_dns = ""
          ec2machine.private_dns = ""
          ec2machine.public_ip = ""
          ec2machine.save
        end
      else
        cmd = Cmd.start_machine_iland(self, self.ilandmachine)
        state =Cmd.run_power_command_iland(cmd)
        if state == "Success"
          self.state = "Run"
          self.is_busy = 1
          self.save
        end
      end
    end  
  end
  
  def reboot
    if self.ec2machine
      cmd = Cmd.reboot_machine(self, self.ec2machine)
      Cmd.run_power_command(cmd)
    elsif self.ilandmachine
      self.is_busy = 1
      self.save
      cmd = Cmd.reboot_machine_iland(self, self.ilandmachine)
      state = Cmd.run_power_command_iland(cmd)
      if state == "Success"
        self.state = "Run"
        self.is_busy = 0
        self.save
      end
    end
  end
  
  #choose the availability zone
  def pick_az
    if self.instancetype.name != "c1.medium" && self.region == 'us-east-1'
      return 'us-east-1a'
    end
    return nil
  end
  
  def is_rdp_opened
    rdp_opened = false
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    cmds = Cmd.find(:all,:conditions => ['job_id = ?', self.id])
    for cmd in cmds
      if cmd.command.include?("-p 3389") && cmd.state == "Success"
        if cmd.command.include?(config["change_group_port"])
          rdp_opened = true
        else
          rdp_opened = false
        end
      end
    end
    return rdp_opened
  end

end
