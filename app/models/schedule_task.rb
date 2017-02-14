require 'popen4'
class ScheduleTask < ActiveRecord::Base
  
  @@config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
  @@database = YAML.load_file(RAILS_ROOT + "/config/database.yml")
  @@pk = @@config["ec2_bin_path"] + @@config["pk"]
  @@cert = @@config["ec2_bin_path"] + @@config["cert"]
  @@deploy_count = 0
  @@recover_count = 0
  @@apipath = @@config["iland_api_jar_path"]
  @@configpath = @@config["iland_configuration_path"]
  
  def self.update_ec2machine_public_dns
    update_ec2machine_public_dns_by_list(nil)  
  end
  #Process getting ip when the load it high
  def self.update_ec2machine_public_dns_2
    machinelist = Ec2machine.find(:all,:conditions => "((public_ip = '' or public_ip is null) and public_dns not like 'ec2%') and status != 'UnDeployed'", :order=> "id desc")  
    if machinelist.size > 14
      update_ec2machine_public_dns_by_list(machinelist.first(15))
    end
  end
  
  # encapsulate into a method so testing would be easier
  def self.update_ec2machine_public_dns_by_list(machinelist)
    got_count = 0
    if machinelist.nil?
      machinelist = Ec2machine.find(:all,:conditions => "((public_ip = '' or public_ip is null) and public_dns not like 'ec2%') and status != 'UnDeployed'")
    end  
    machinelist.each do |ec2machine|
      begin
        job = Job.find_by_ec2machine_id(ec2machine.id)
        if job != nil && (job.state == "Run" or job.state == "Open")
          puts "get dns for job: " + job.id.to_s
          got_count = got_count + 1
          if got_count > 15
            puts "break the loops to avoid long time running"
            break
          end       
          instanceid = ec2machine.instance_id
          command = @@config["ec2_bin_path"] + @@config["get_instance_command"]
          cmd = command + ' ' + instanceid + ' -K ' + @@pk +' -C ' + @@cert + ' --region ' + job.template.region
          strs = IO.popen(cmd)
          sleep(1)        
          lines = Array.new
          i = 0        
          while line=strs.gets
            lines[i] = line
            i = i + 1
          end 
          if lines.length > 0
            if (lines[1]!=nil)
              record = lines[1].split("\x09") 
              ec2machine.public_dns = record[3]
              ec2machine.private_dns = record[4]
              ec2machine.zone = record[11]
              template = Template.find_by_ec2_ami(job.ami_name)
              ec2machine.platform = template.platform
              ec2machine.local_launch_time = DateTime.now
              ec2machine.block_devices = record[20]
              ec2machine.key_pair = record[6]
              ec2machine.status = "Deployed"
              ec2machine.lifecycle = job.deploymentway
              ec2machine.security_group = job.securitytype_name
              ec2machine.public_ip = record[16]
              ec2machine.private_ip = record[17]
              ec2machine.sg_id = record[28]
              if !ec2machine.public_dns.include?("ec2")
                ec2machine.public_dns = ec2machine.public_ip
              end
              if lines[1].include?("ebs") && lines[2] != nil
                blockdevices = lines[2].split(" ")
                ec2machine.block_devices = blockdevices[1] + "=" + blockdevices[2] + ":attached:" + blockdevices[3]
              end
              ec2machine.save
              if ec2machine.public_dns.include?("ec2") || ec2machine.public_ip != ""
                content = "Your deployed job " + job.name + " is ready to use. <br>"
                content = content + "For more detail please view https://vdi.devfactory.com/jobs/" + job.id.to_s
                content = content + "<br> The public DNS of the machine is: " + ec2machine.public_dns
                Email.create_job_notification(job, "Job Launched", content)
              else
                puts "Something went wrong when updating the dns: " + job.id.to_s
                puts cmd
                if lines[1].include?('terminated')
                  puts "Amazon failure: " + job.id.to_s
                  if (Time.now - job.updated_at) > 300 && (Time.now - job.created_at) < 3600
                    # job deploy failed by amazon failure
                    ec2machine.status = "UnDeployed"
                    ec2machine.save
                    deploy_normal_instance(job)
                    job.state = "Deploying"
                    job.save
                    error_mail_sub = "Amazon deployment error: " + ec2machine.instance_id.to_s
                    error_mail_content = "This instance is teminated un-expected: " + ec2machine.instance_id.to_s
                    Email.mail_to_admin(error_mail_sub, error_mail_content)                  
                  elsif (Time.now - job.created_at) > 3600
                    ec2machine.status = "UnDeployed"
                    ec2machine.save
                    falsetoprocess(job)
                  end
                end            
              end            
            end
          end
        elsif !job.nil? && job.state == "PowerOFF"
          #Mark the instance as poweroff
          ec2machine.public_ip = "ec2.poweroff"
          ec2machine.save
        elsif job == nil || (job.state == "Undeploy" || job.state == "Build Fail" || job.state == "Spot Fail" || job.state == "Expired")
          # Commit this handler out temporary. need logic improvement here        
          #delete_instance_command = @@config["ec2_bin_path"] + @@config["delete_instance_command"]
          #cmd = delete_instance_command + ' ' +  ec2machine.instance_id.to_s + ' -K ' + @@pk +' -C ' + @@cert + ' --region ' + job.template.region
          #state = run_command(cmd)
          #if state
          #  ec2machine.status = "UnDeployed"
          #else
          #  ec2machine.status = "Dirty"
          #end
          ec2machine.status = "UnDeployed"
          ec2machine.save
          error_mail_sub = "Dirty machine found: " + ec2machine.instance_id.to_s
          error_mail_content = "Dirty machine found for instance id: " + ec2machine.instance_id.to_s
          Email.mail_to_admin(error_mail_sub, error_mail_content)
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
      sleep 1
    end
  end
  
  def self.delete_job_ec2machine_and_update_security_type
    Job.find(:all,:conditions => ["lease_time <= now() and state in ('Run', 'PowerOFF')"] ).each do |job|
      begin
        if job.state == "Run" || job.state == "PowerOFF"
          puts "Job expired: " + job.id.to_s
          job.deletejob(job)
          job.state = "Expired"
          job.save
          
          content = "Your deployed job: " + job.name + " have force undeployed by lease time out <br>" 
          content = content + "For more detail please view http://vdi.gdev.com/jobs/" + job.id.to_s
          Email.create_job_notification(job, "Job Expired", content)
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
      sleep 5
    end
  end
  
  #delete securitytype
  def self.delete_security_type
    Securitytype.find(:all,:conditions => "state = 'shut_down'", :limit => "50").each do |securitytype|
      begin  
        job = Job.find(:first, :conditions => "securitytype_name = '#{securitytype.name}'")
        if Job::STATUS[:active].include?(job.state)
          puts "Job is still running" + job.id.to_s
          securitytype.state = 'Pending'
          securitytype.save
        end
        delete_securitytype_command = @@config["ec2_bin_path"] + @@config["delete_securitygroup_command"]
        cmd = delete_securitytype_command + ' -K ' + @@pk +' -C ' + @@cert + ' --region ' + securitytype.region
        if securitytype.securitygroup_id.blank?
          cmd = cmd + " " + securitytype.name
        else
          cmd = cmd + " " + securitytype.securitygroup_id
        end
        puts "removing: " + securitytype.name
        POpen4.popen4(cmd) do |stdout, stderr, stdin, pid|
          status_err = stderr.read.strip
          if status_err != nil && status_err != ""
            puts status_err
            if status_err.include?("Client.InvalidGroup.NotFound")
              #If the group does not exists. Set it as undeploy
              securitytype.state = "Undeploy"
              securitytype.save
            end
            #Remove security failed, do nothing
          else 
            securitytype.state = "Undeploy"
            securitytype.save
          end
        end
        
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
      sleep 9
    end
  end
  
  def self.check_spot_requests(region)
    check_spot_requests_command = @@config["ec2_bin_path"] + @@config["check_spot_requests"]
    cmd = check_spot_requests_command + ' -K ' + @@pk + ' -C ' + @@cert + ' --region ' + region
    str = IO.popen(cmd)
    sleep(2)
    lines = Array.new
    i=0
    while line=str.gets
      lines[i] = line
      i = i + 1
    end  
    for spotline in lines
      begin
        spotrecords = spotline.split(" ")
        cancel_spot_requests_command = @@config["ec2_bin_path"] + @@config["cancel_spot_requests"]
        cancelcmd = cancel_spot_requests_command + ' ' + spotrecords[1] + ' -K ' + @@pk + ' -C ' + @@cert + ' --region ' + region
        if spotrecords[5] == "active"
          job = Job.find(:first, :conditions => ["request_id = :request_id", {:request_id => spotrecords[1]}])
          if job
            if job.deploymentway != "Spot"
              # the machine is already deployed in normal way
              puts "This job has dirty machines: " + job.id_s
              
              error_mail_sub = "Dirty Spot instance found"
              error_mail_content = "Dirty spot instance found: " + job.id.to_s
              Email.mail_to_admin(error_mail_sub, error_mail_content)
              # run_command(cancelcmd)
              next
            end
            if job.state == 'Open' || job.state == 'Build Fail'
              ec2machine = Ec2machine.new()
              ec2machine.instance_id = spotrecords[7]
              initialec2machine(ec2machine)
              job.ec2machine_id = ec2machine.id
              job.state = "Run"
              job.updated_at = Time.now
              job.save
            end
          end
        elsif spotrecords[5] == "closed"
          IO.popen(cancelcmd)
          sleep(1)
        elsif spotrecords[5] == "open"
          job = Job.find(:first, :conditions => ["request_id = :request_id", {:request_id => spotrecords[1]}])
          if job && Time.now - job.updated_at > 660
            state = run_command(cancelcmd)
            if state
              sleep(1)
              deploy_normal_instance(job)
              job.state = "Pending"
              job.deploymentway = "normal"
              job.save
            end
          end
        elsif spotrecords[5] == "cancelled" || spotrecords[5] == "failed"
          job = Job.find(:first, :conditions => ["request_id = :request_id and state = 'Open'", {:request_id => spotrecords[1]}])
          if job
            deploy_normal_instance(job)
            job.state = "Pending"
            job.deploymentway = "normal"
            job.save
          end
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
    end
  end
  
  def self.run_command(cmd)
    POpen4.popen4(cmd) do |stdout, stderr, stdin, pid|
      status_err = stderr.read.strip
      if status_err != nil && status_err != ""
        return false
      else 
        return true
      end
    end
  end
  
  def self.deploy_normal_instance(job)
    old_cmd = Cmd.find(:first, :conditions =>("job_id = #{job.id} and description = 'Create Normal Instance'"))
    cmd = Cmd.new
    cmd.job_id = job.id
    instancetype = Instancetype.find(job.instancetype_id).name
    instancecommand = @@config["ec2_bin_path"] + @@config["create_instance"]
    instancecmd = instancecommand + ' ' +  job.ami_name + ' -g ' + job.securitytype_name + ' -k ' + @@config["key-pair"]
    instancecmd = instancecmd + ' --instance-type ' + instancetype + ' -K ' + @@pk +' -C ' + @@cert + ' --region ' + job.template.region
    cmd.created_at = Time.now
    cmd.updated_at = Time.now
    cmd.description = "Recover deployment" 
    cmd.command = instancecmd
    if old_cmd != nil and !old_cmd.command.blank?
      cmd.command = old_cmd.command
    end   
    cmd.state = "Pending"
    cmd.job_type = "C"
    cmd.save
  end
  
  def self.deploy_job(job)
    if job.state != "Deploying"
      job.state = "Deploying"  
      job.save
    end
    puts "Start deploy job: " + job.id.to_s
    cmds = Cmd.find(:all,:conditions => ["job_id = :job_id and job_type= :create", {:job_id =>job.id,:create=>"C"}])
    cmds.each do |cmd|
      commandLine = cmd.command
      # Skip the duplicate deployment
      if commandLine.include?(@@config["create_instance"]) || commandLine.include?(@@config["create_spot_instance"])
        updatedCMD = Cmd.find(cmd.id) 
        if updatedCMD.state != nil && updatedCMD.state != "" && updatedCMD.state != "Pending"
          if updatedCMD.state == "Fail"
            break
          elsif updatedCMD.state == "Running"
            # Skip running command
            break
          elsif commandLine.include?(@@config["create_spot_instance"])
            # If spot deployment, set it to Open and the spot request is the last command
            if cmds[(cmds.size) -1].id == updatedCMD.id
              job.state = "Open"
            else
              next
            end
          else
            job.state = "Run"
          end
          job.save
          next
        end
        cmd.state = "Running"
        cmd.save
      end  
      # Skip success command
      if cmd.state == "Success"
        puts "Skip successed command: " + cmd.command
      else
        #Sometimes, the command update was failed.
        if commandLine.include?('$securitygroup_id')        
          update_securitygroup_id(job)
          job.state = "Pending"
          job.save
          set_cmd_retry(cmd, job, "SecurityGroup was not replaced")
          break
        end
        sleep 2
        POpen4.popen4(commandLine) do |stdout, stderr, stdin, pid|
          status_out = stdout.read.strip
          status_err = stderr.read.strip          
          #puts status_out
          #puts "Error:"
          #puts status_err
          if status_out != nil && status_out != ""
            cmd.state = "Success"
            cmd.updated_at = Time.now
            cmd.save
            lines = status_out.split("\n")
            if lines[0]
              records = lines[0].split(" ")
              #Update the security group ids. since VPC deployment need security group id. the name does not work for vpc
              if commandLine.include?(@@config["add_group"]) && records[1] && records[1].include?("sg-")
                group = Securitytype.find_by_name(job.securitytype_name)              
                group.securitygroup_id = records[1]              
                group.save
                update_all_securitygroup_id(job, group.securitygroup_id)
                if job.is_vpc
                  #restart the deploymented once have the group created for vpc deployment
                  job.state = "Pending"
                  job.save
                  break
                end
              end
            end
            if lines[1]
              records = lines[1].split(" ")
              if records[1] && records[1].include?("i-")
                ec2machine = Ec2machine.new()
                ec2machine.instance_id = records[1]
                initialec2machine(ec2machine)
                job.ec2machine_id = ec2machine.id
                job.state = "Run"
                job.save
                puts "Job deployed: " + job.id.to_s
                break              
              end
            end
            if status_out.include?("sir-")
              requests = status_out.split(" ")
              job.request_id = requests[1]
              job.state = "Open"
              puts "Job deployed: " + job.id.to_s
              job.save
              break
            end
          else
            if status_err == nil || status_err == "" || status_err.include?("Client.InvalidPermission.Duplicate") || 
              status_err.include?("Client.InvalidGroup.Duplicate")
              # This error is because of re-add ports to security group, we can treat the command success.
              cmd.state = "Success"
              cmd.updated_at = Time.now
              cmd.save
            else
              puts status_err
              puts cmd.command
              set_cmd_retry(cmd, job, status_err)
              break;
            end
          end
        end
      end
    end
    puts "Deployment of job: " + job.id.to_s + " is complete."
  end
  
  def self.set_cmd_retry(cmd, job, error_log)
    if cmd.retry < 3
      #Retry the command if the failure is less than 3
      cmd.retry = cmd.retry + 1
      cmd.state = 'Pending'
      cmd.error_log = error_log
      cmd.save
    else
      cmd.error_log = error_log
      cmd.save
      falsetoprocess(job)
    end  
  end
  
  def self.create_instances_task
    @@deploy_count = @@deploy_count + 1
    puts "Deploy count: " + @@deploy_count.to_s
    if @@deploy_count >= 2
      puts "To many deployment process running, skip it"
      @@deploy_count = @@deploy_count - 1
      return
    end
    skip_count = 0
    jobs = Job.find(:all, :conditions => "state in ('Pending', 'Deploying') and (region != 'iland' or region is null)")
    jobs.each do |job|
      begin
        job = Job.find(job.id)
        if job.state == "Run"
          puts "Skip machine deployment, another task is running"
          next
        end
        if job.state == "Deploying"
          pendingjobs = Job.find(:all, :conditions => "state in ('Pending') and (region != 'iland' or region is null)")
          if pendingjobs.size > 0
            # If there are pending jobs. deploy pending jobs first. 
            # If there is no pening jobs, redeploying deploying job
            next
          else
            # Skip some deploying jobs since others are working on it          
            if skip_count == (@@recover_count + @@recover_count) || jobs.size <= (@@recover_count + @@recover_count) 
              skip_count = 0
              deploy_job(job)        
            else  
              skip_count = skip_count + 1
              puts "Skip deployment: " + job.id.to_s
              next
            end
          end
        end
        deploy_job(job)
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
        falsetoprocess(job)
      end
    end
    @@deploy_count = @@deploy_count - 1
  end
  
  def self.wtire_current_task_time(config_file)
    aFile = File.new(config_file, "w")
    currentTime = Time.now
    hour = currentTime.hour
    min = currentTime.min
    aFile.puts hour * 60 + min
    aFile.close  
  end
  
  def self.cleanup_dead_deployment(minutes_created = 9 , minutes_updated = 2, order_fields = "")
    @@recover_count = @@recover_count + 1
    puts "Recover count: " + @@recover_count.to_s
    if @@recover_count >= 2
      puts "To many recover process running, skip it"
      @@recover_count = @@recover_count - 1
      return
    end

    if order_fields.empty?
      jobs = Job.find(:all, :conditions => "state in ('Deploying') and (region != 'iland' or region is null)")
    else
      jobs = Job.find(:all, :conditions => "state in ('Deploying') and (region != 'iland' or region is null)", :order=> "id desc")
    end
    jobs.each do |job|
      begin
        job = Job.find(job.id)
        if job.state == "Run"
          puts "Skip machine deployment, another task is running"
          next
        end
        if job.state == "Deploying"
          if minutes_updated == 0
            if job.created_at > Time.now - minutes_created * 60
              # If the job deployed less than 11 mins, skip it
              next
            end
          else
            if (job.created_at > Time.now - minutes_created * 60) && (job.updated_at > Time.now - minutes_updated * 60)
              # If the job deployed less than 11 mins, skip it,and the job update time is less than 2 minutes
              next
            end
          end
        end
        deploy_job(job)
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
        falsetoprocess(job)
      end
    end
    @@recover_count = @@recover_count - 1
  end

  def self.initialec2machine(ec2machine)
    now_time = Time.now
    ec2machine.public_dns = ''
    ec2machine.private_dns = ''
    ec2machine.created_at = now_time
    ec2machine.updated_at = now_time
    ec2machine.zone = ''
    ec2machine.platform = ''
    ec2machine.virtualization = ''
    ec2machine.block_devices = ''
    ec2machine.lifecycle = ''
    ec2machine.security_group = ''
    ec2machine.key_pair = ''
    ec2machine.local_launch_time = ''
    ec2machine.status = ''
    ec2machine.save
  end
  
  def self.falsetoprocess(job)
    remove_securitygroup(job)
    
    Cmd.find(:all,:conditions => ["job_id = :job_id and state = 'Pending'", {:job_id =>job.id}]).each do |cmd|
      cmd.state = "Fail"
      cmd.save
    end
    job.state = "Build Fail"
    job.save
    
    content = "Your deployed job " + job.name + " is failed to deploy <br>" 
    content = content + "For more detail please view http://vdi.gdev.com/jobs/" + job.id.to_s
    Email.create_job_notification(job, "Job Failed", content)
    error_sub = "[gDevVDI] -- Deploy Failed: " + job.id.to_s
    Email.mail_to_admin(error_sub, content)
  end
  
  def self.remove_securitygroup(job)
    Securitytype.find(:all, :conditions => ['name = ?', job.securitytype_name]).each do |securitytype|
      securitytype.state = "shut_down"
      securitytype.save
    end
  end
  
  def self.send_mail
    m = Mutex.new
    m.synchronize {
      puts "Start send email thread"
      emails = Email.find(:all, :conditions => ["send_successful = 0 and send_count < 3 and (status<=>null or status='fail')"], :limit=>@@config["send_mail_interval"] * 60)
      ids = ""
      emails.each{|e| ids +=e.id.to_s+","}
      ids.chop! if ids != ""
      puts "#{emails.size} should be sent."
      ActiveRecord::Base.connection.execute("update emails set status='Pending' where id in (#{ids})") if ids != ""
      puts "Put into queue."
      emails = Email.find(:all, :conditions => ["status='Pending'"], :limit=>@@config["send_mail_interval"] * 20)
      for email in emails do
        begin
          if email.mailer == "demo_mailer"
            EmailsMailer.set_to_demo_mailer
          else
            EmailsMailer.set_to_default_mailer
          end
          
          EmailsMailer.deliver_send(email)
          
          if email.mailer == "demo_mailer"
            EmailsMailer.set_to_default_mailer                
          end
          puts "#{email.id}-#{email.subject} has been sent out."
          email.send_successful = 1
          email.status = "successful"
        rescue => e
          email.send_successful = 0
          email.status = "fail"
          puts "*****************************************","An exception happened when sending email #{email.subject}","The Exception is:#{e.inspect}","*****************************************"
        ensure
          email.update_at = Time.now
          email.send_count = email.send_count + 1            
          email.save
          #Email.delete_all(:send_successful=>1)
        end
      end
    }  
  end
  
  def self.connect_telnet_service
    jobs = Job.find(:all, :conditions => "state in ('Run') and telnet_service = 'stop'")
    if jobs.size != 0
      jobs.each do |job|
        begin
          environment = @@config["environment"]
          dbName = @@database[environment]["database"]
          dbPassword = @@database[environment]["password"].to_s
          dbIp = @@database[environment]["host"]
          dbUser = @@database[environment]["username"]
          platform = Template.find(job.template_id).platform
          commandStr = 'java -jar ' + @@config["java_jar_path"] + ' ' + '"' + platform + '"' + ' ' + '"' + dbName + '"' + ' ' + '"' + dbPassword + '"' + ' ' + '"' + dbIp + '"' + ' ' + '"' + job.id.to_s + '"' + ' ' + '"' + dbUser + '"'
          p commandStr
          IO.popen(commandStr)
        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
        end
      end
    end
  end
  
  def self.run_telnet_commands
    jobs = Job.find(:all, :conditions => "state = 'Run' and telnet_service = 'start'")
    if jobs.size != 0
      jobs.each do |job|
        telnetcommands = Runcommand.find(:all, :conditions => "state = 'Pendding' and job_id = " + job.id.to_s )
        if telnetcommands.size != 0
          begin
            environment = @@config["environment"]
            dbName = @@database[environment]["database"]
            dbPassword = @@database[environment]["password"].to_s
            dbIp = @@database[environment]["host"]
            dbUser = @@database[environment]["username"]
            ec2machine = Ec2machine.find(job.ec2machine_id)
            public_dns = ec2machine.public_dns
            template = Template.find(job.template_id)
            platform = template.platform
            account = template.user
            password = template.password.to_s
            commandStr = 'java -jar ' + @@config["java_jar_path"] + ' ' + '"' + public_dns + '"' + ' ' + '23' + ' ' + '"' + account + '"' + ' ' + '"' + password + '"' + ' ' + '"' + platform + '"' + ' ' + '"' + dbName + '"' + ' ' + '"' + dbPassword + '"' + ' ' + '"' + dbIp + '"' + ' ' + '"' +  job.id.to_s + '"' + ' ' + '"' + dbUser + '"'
            p commandStr
            IO.popen(commandStr)
          rescue Exception => e
            puts e.message
            puts e.backtrace.inspect
          end
        end
      end
    end
  end
  
  def self.recover_dead_deployment
    jobs = Job.find(:all, :conditions => "(state in ('Deploying', 'Open') or (state in ('Run', 'PowerOFF') and ec2machine_id is null)) and (region != 'iland' or region is null)")  
    if jobs.size != 0
      jobs.each do |job|
        if Time.now - job.updated_at < 180
          next
        end
        active_machines = ActiveMachine.find(:first, :conditions => "security_group = '#{job.securitytype_name}'")
        if active_machines.nil?
          #In case it's a vpc deployment, there is not securitygroup name in the active machine
          securitytype = Securitytype.find_by_name(job.securitytype_name)
          if !securitytype.securitygroup_id.blank?
            active_machines = ActiveMachine.find(:first, :conditions => "sg_id = '#{securitytype.securitygroup_id}'")
          end
        end      
        if active_machines != nil
          ec2machine = Ec2machine.new()
          ec2machine.instance_id = active_machines.instance_id
          ec2machine.public_dns = ""
          ec2machine.status = 'Deployed'
          ec2machine.save
          job.ec2machine_id = ec2machine.id
          job.state = "Run"
          job.save
          puts "Job recovered: " + job.id.to_s
        else
          dead_time = Time.now - job.updated_at
          if dead_time > 3600
            puts "Job keep deploying for too long time: " + job.id.to_s
            error_mail_sub = "Dead Deployment found"
            error_mail_content = "Dead Deployment found for: " + job.id.to_s
            Email.mail_to_admin(error_mail_sub, error_mail_content)
            falsetoprocess(job)
          elsif dead_time > 900 && dead_time <= 3600
            #If the command keep running for long time, re-run the command
            Cmd.recover_cmds(job)
          end
        end
      end
    end
  end
  
  def self.pending_job_warning
    jobs = Job.find(:all, :conditions => "state in ('Deploying', 'Pending') and (region != 'iland' or region is null)")
    if jobs.size >= 15
      puts "Too many pending jobs: " + jobs.size.to_s
      error_mail_sub = "Too many pending jobs: " + jobs.size.to_s
      error_mail_content = "Too many pending jobs: " + jobs.size.to_s
      Email.mail_to_admin(error_mail_sub, error_mail_content)
    end
  end 
  
  def self.check_volumes
    Ebsvolume.find(:all, :conditions=> "status in('pending', 'creating', 'attaching', 'detaching')").each do |volume|
      begin
        get_volume_command = @@config["ec2_bin_path"] + @@config["get_volume_command"] + " -C " + @@cert + " -K " + @@pk + ' --region ' + volume.region
        get_volume_command = get_volume_command + " " + volume.volume_id
        strs = IO.popen(get_volume_command)
        sleep(1)
        i = 0
        lines = Array.new
        while line=strs.gets
          lines[i] = line
          i = i + 1
        end
        if lines.length >= 1 && lines[0].include?("vol-") && lines[0].include?('VOLUME')
          ## parse the resevation line
          record = lines[0].split(" ")
          j = 0
          if !record[3].include?('snap-')
            j = -1
          end
          status = record[5 + j]
          if status == "in-use" && lines[1]
            if lines[1].include?('attaching')
              status = "attaching"
            elsif lines[1].include?('detaching')
              status = "detaching"
            else
              status = "attached"
            end
          end
          
          if volume.status != status
            volume.status = status
            volume.save
          end
        end      
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect    
      end    
    end 
  end
  
  def self.check_snapshots
    Snapshot.find(:all, :conditions=> "status in('pending', 'creating')").each do |snapshot|
      begin
        get_snapshot_command = @@config["ec2_bin_path"] + @@config["get_snapshot_command"] + " -C " + @@cert + " -K " + @@pk + ' --region ' + snapshot.region
        get_snapshot_command = get_snapshot_command + " " + snapshot.snapshot_id
        strs = IO.popen(get_snapshot_command)
        sleep(1)
        i = 0
        lines = Array.new
        while line=strs.gets
          lines[i] = line
          i = i + 1
        end
        if lines.length >= 1 && lines[0].include?("snap-") 
          ## parse the resevation line
          record = lines[0].split(" ")
          if snapshot.status != record[3]
            snapshot.status = record[3]
            snapshot.save
          end
        end      
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect    
      end    
    end   
    
  end
  #TODO: Fix the issue if this is a demo from ilandmachine
  #Fixed: The above issue has been fixed by adding case in DemoJob.apply_tokens
  def self.check_demo_jobs
    DemoJob.find(:all, :conditions=> "state in('Pending')").each do |demojob|
      begin
        job = demojob.job
        if job.state == 'Run' && ((job.ec2machine && job.ec2machine.public_dns.include?("ec2")) || job.ilandmachine)
          demojob.state = 'Run'
          demojob.save
          DemoJob.send_ready_mail(demojob)
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect    
      end    
    end   
  end
  
  def self.update_all_securitygroup_id(job, securitygroup_id)
    cmds = Cmd.find(:all, :conditions=>"job_id = #{job.id}")
    cmds.each do |cmd|
      begin
        if cmd.command.include?('$securitygroup_id')
          cmd.command = cmd.command.gsub(/\$securitygroup_id/, securitygroup_id)
          cmd.save
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect    
      end  
    end
  end
  def self.update_securitygroup_id(job)
    cmds = Cmd.find(:all, :conditions=>"job_id = #{job.id}")
    group = Securitytype.find_by_name(job.securitytype_name)
    if group.securitygroup_id.blank?
      #TODO: Need to load active security groups to check whether the create is actually created.
      puts 'The secuitry group does not have securitygroup id updated: ' + group.name
      return
    end
    cmds.each do |cmd|
      begin
        if cmd.command.include?('$securitygroup_id')
          cmd.command = cmd.command.gsub(/\$securitygroup_id/, group.securitygroup_id)
          cmd.save
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect    
      end  
    end
  end
  
  def self.assign_vpc_elasticip
    sql = "select j.* from 
           (select * from jobs where state = 'Run' and deploymentway in ('vpc-default', 'vpc-dedicated')) as j
         left join ec2machines e
         on j.ec2machine_id = e.id
         where e.public_ip = '' or e.public_ip is null"
    running_vpc_jobs = Job.find_by_sql(sql)
    running_vpc_jobs.each do |job|
      begin
        ip = Elasticip.find(:first, :conditions=>"job_id = #{job.id} and deleted = 0")
        if ip.nil?
          ip = Elasticip.new
          ip.region = job.template.region
          ip.user_id = job.user_id
          ip.scope = 'vpc'
          ip.name = 'Elastic IP for job ' + job.id.to_s
          ip.job_id = job.id
          result = Elasticip.create(ip)
          if result == "Fail"
            #Create IP failed. then skip the process
            next
          end
        end
        Elasticip.attach(ip)
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect    
      end   
    end       
  end
  
  def self.cleanup_vpc_elasticip
    sql = "select e.* from 
          (select * from elasticips where job_id is not null and deleted = 0) as e
         left join jobs j
         on j.id = e.job_id
         where j.state in ('Build Fail', 'Undeploy', 'Expired')"
    dead_ips = Elasticip.find_by_sql(sql)
    dead_ips.each do |ip|
      begin
        Elasticip.delete(ip)
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect    
      end   
    end    
  end
  
  def self.deploy_ilandmachine
    
    deploy_ilandmachine_list(nil)
  end
  
  def self.deploy_ilandmachine_list(joblist)
    if joblist.nil?
      joblist = Job.find(:all,:conditions => "state = 'Deploying' and region = 'iland'")
    end  
    
    joblist.each do |job|
      begin
        job = Job.find(job.id)
        if job.state != "Deploying"
          #Skip if the job state has been changed
          next
        end
        
        if job.is_busy == 1 && job.updated_at > Time.now - 5*60
          #Other thread running the commands in 5 minutes ago. Skip it
          next
        end
        job.is_busy = 1
        job.save
        
        cmdlist = Cmd.find(:all, :conditions=>"state in ('Pending', 'Running') and job_id = #{job.id}")        
        
        cmdlist.each do | cmd |
          cmd = Cmd.find(cmd.id)
          if cmd.state == 'Success'
            next
          end
          if cmd.state == 'Running' && cmd.updated_at > Time.now - 6*60
            #if command keeps running for more than 6 mins, re-run it. otherwise skip it.
            break
          end
          cmd.state = 'Running'
          cmd.save
          newvm_command = @@config["iland_create_vm"]
          startvm_command = @@config["iland_start_instances"]
          if cmd.command.include?(newvm_command)
            #Run new VM
            messagearray = ""
            ilandmachine = job.ilandmachine
            
            POpen4.popen4(cmd.command) do |stdout, stderr, stdin, pid|
              std_err = stderr.read.strip
              std_out = stdout.read.strip
              if !std_err.include?("Exception") && std_out != "no vm"&&std_out != nil
                messagearray = std_out.split(/,/)                
                ilandmachine.instance_id = messagearray[1]
                ilandmachine.private_dns = messagearray[0]
                ilandmachine.public_dns = Job.get_iland_public_ip(ilandmachine.private_dns)
                ilandmachine.created_at = Time.now
                ilandmachine.status = "Deployed"
                ilandmachine.save
                cmd.state = "Success"
                cmd.save
              else
                cmd.state = "Fail"
                cmd.save
                #If the command fail, break this turn, and retry next turn
                retry_iland_command(cmd, job, std_err)
                job.is_busy = 0
                job.save
                break
              end              
            end
          elsif cmd.command.include?(startvm_command)  
            POpen4.popen4(cmd.command) do |stdout, stderr, stdin, pid|
              status_err = stderr.read.strip
              status_out = stdout.read.strip
              if !status_err.include?("Exception")&&status_out == "true"
                cmd.state = "Success"
                cmd.save
                job.state = "Run"
                job.save
              else
                cmd.state = "Fail"
                retry_iland_command(cmd, job, status_err)
                job.is_busy = 0
                job.save
                break
              end
            end
          end
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
    end
  end
  
  def self.retry_iland_command(cmd, job, error_log)
    if cmd.retry < 3
      #Retry the command if the failure is less than 3
      cmd.retry = cmd.retry + 1
      cmd.state = 'Pending'
      cmd.error_log = error_log[error_log.length-255 , error_log.length-1]
      cmd.save
    else
      cmd.error_log = error_log[error_log.length-255 , error_log.length-1]
      cmd.save
      job.state = 'Build Fail'
      job.save
      #TODO: here need undeploy the vapp
      instanceid = job.ilandmachine.vapp_id
      jobcommand = @@config["iland_delete_vapp"]
      deletecommand = "java -cp #{@@apipath} #{jobcommand} #{@@configpath} #{instanceid}"
      POpen4.popen4(deletecommand) do |stdout, stderr, stdin, pid|
        status_err = stderr.read.strip
        std_out = stdout.read.strip
        if !status_err.include?("Exception") && std_out=="true"
          job.state = "Success"
          job.save
        else
          job.is_busy = 0
          job.state = "Build Fail"
          job.save
        end
      end
    end  
  end
  
  def self.undeploy_ilandmachine
    joblist = Job.find(:all,:conditions => "state in ('Undeploy', 'Expired') and region = 'iland' and is_busy = 1")
    joblist.each do |job|
      job = Job.find(job.id)
      if job.state != "Undeploy"  && job.state != "Expired" 
        #Skip if the job state has been changed
        next
      end
      
      if job.is_busy == 1 && job.updated_at > Time.now - 1*60
        #Other thread running the commands in 5 minutes ago. Skip it
        next
      end
      job.is_busy = 1
      job.save
      
      job_id = job.id
      cmds = Cmd.find(:all,:conditions => "job_id = #{job_id} and state = 'Pending'")  
      cmds.each do |cmd|
        begin
          cmd = Cmd.find(cmd.id)
          if cmd.state == 'Success'
            next
          end
          cmd.state = 'Running'
          cmd.save
          poweroffvm_command = @@config["iland_stop_instances"]
          deletevapp_command = @@config["iland_delete_vapp"]
          if cmd.command.include?(poweroffvm_command)
            POpen4.popen4(cmd.command) do |stdout, stderr, stdin, pid|
              status_err = stderr.read.strip
              std_out = stdout.read.strip
              if !status_err.include?("Exception") && std_out=="true"
                cmd.state = "Success"
                cmd.save
              else
                job.save
                cmd.state = "Fail"
                cmd.save
              end
            end
            break
          elsif cmd.command.include?(deletevapp_command)
            POpen4.popen4(cmd.command) do |stdout, stderr, stdin, pid|
              status_err = stderr.read.strip
              std_out = stdout.read.strip
              if !status_err.include?("Exception") && std_out=="true"
                cmd.state = "Success"
              else
                cmd.state = "Fail"
              end
              cmd.save
              job.is_busy = 0
              job.save
            end
          end
        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
        end
      end
    end
  end
  
  #Check the vapp status when it's created. Once it's created, change the machine to deploying, and add command 
  #new vm and power the vm
  def self.get_status_of_vapp
    jobs = Job.find(:all, :conditions=>"state = 'Pending' and region = 'iland'")
    jobs.each do |job|
      begin
        result = ""
        job = Job.find(job.id)
        if job.state != 'Pending'
          #Skip if the job state has been changed
          next
        end
        ilandmachine = job.ilandmachine
        vappid = ilandmachine.vapp_id
        getvappstatus = @@config["iland_get_vapp_status"]
        getvmstatuscmdLine = "java -cp #{@@apipath} #{getvappstatus} #{@@configpath} #{vappid}"
        POpen4.popen4(getvmstatuscmdLine) do |stdout, stderr, stdin, pid|
          status_err = stderr.read.strip
          status_out = stdout.read.strip
          if !status_err.include?("Exception")
            result =  status_out
          else
            puts "Run cmd " + getvmstatuscmdLine + " failed: " + status_err
            result = 'fail'
          end
        end
        if result == "0" and job.created_at > Time.now - 60*60
          #If failed to get vapp for more than 30 minutes, skip it.
          next
        elsif result == 'fail'||(result == "0" && job.created_at <= Time.now - 60*60)
          #Get vpp status failed means the vpp creation failed
          job.state = 'Build Fail'
          job.save
          ilandmachine.status = 'Undeployed'
          ilandmachine.save
          next
        end
        
        #The vapp is created, change the job to deploying
        #Add new vm command
        jobcommand = @@config["iland_create_vm"]
        name = job.name
        instancetype = Instancetype.find(job.instancetype_id)
        memorysize = instancetype.memorysize
        cpusize = instancetype.cpusize
        cmdLine = "java -cp #{@@apipath} #{jobcommand} #{@@configpath} #{vappid} \"#{name}\" #{memorysize} #{cpusize}"
        cmd = Cmd.new()
        cmd.job_id = job.id
        cmd.command = cmdLine
        cmd.state = "Pending"
        cmd.job_type = "C"
        cmd.description = "New VM"
        cmd.save
        
        #Add power command
        startvm = @@config["iland_start_instances"]
        startvmcmdLine = "java -cp #{@@apipath} #{startvm} #{@@configpath} #{vappid}"
        statevmcmd = Cmd.new()
        statevmcmd.job_id = job.id
        statevmcmd.command = startvmcmdLine
        statevmcmd.state = "Pending"
        statevmcmd.job_type = "C"
        statevmcmd.description = "Power on VM after deploy"
        statevmcmd.save
        
        job.state = 'Deploying'
        job.is_busy = 0
        job.save        
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
    end
  end
  
  def self.get_status_of_ilandmachine
    joblist = Job.find(:all,:conditions => "(state = 'PowerOFF' or state = 'Run') and region ='iland' and is_busy = 1")
    joblist.each do |job|
      begin
        job_id = job.id
        ilandmachine = job.ilandmachine
        if !job.ilandmachine
          job.state = 'Build Fail'
          job.save
          next
        end
        vmhref = ilandmachine.instance_id
        getvmstatus = @@config["iland_get_vm_status"]
        getvmstatuscmdLine = "java -cp #{@@apipath} #{getvmstatus} #{@@configpath} #{vmhref}"
        POpen4.popen4(getvmstatuscmdLine) do |stdout, stderr, stdin, pid|
          status_err = stderr.read.strip
          status_out = stdout.read.strip
          if !status_err.include?("Exception")
            if job.state=="Run"&&status_out=="4"
              job.is_busy = 0
            end
            if job.state=="PowerOFF" && status_out=="8"
              job.is_busy = 0
            end
            job.save
          else
            #TODO: think about the case that check status failed repeatedly.
            if job.updated_at < Time.now - 30 * 60
              error_mail_sub = "Failed to get iland machine status: " + job.id.to_s
              error_mail_content = "Failed to get iland machine status in 30 minutes for: " + job.id.to_s
              Email.mail_to_admin(error_mail_sub, error_mail_content)
              job.state = "Run"
              job.is_busy = 0
              job.save
            end
          end
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
    end
  end
  
  def self.get_status_of_template
    joblist = Job.find(:all,:conditions => "state = 'Capturing' and region = 'iland'")
    joblist.each do |job|
      job = Job.find(job.id)
      if job.state != "Capturing"
        #Skip if the job state has been changed
        next
      end
      
      if job.is_busy == 1 && job.updated_at > Time.now - 5*60
        #Other thread running the commands in 5 minutes ago. Skip it
        next
      end
      job.is_busy = 1
      job.save
      job_id = job.id
      template = Template.find(:first,:conditions => "job_id = #{job_id} and state = 'pending'")
      cmd = Cmd.find(:first, :conditions=>"state = 'capturing' and job_id = #{job_id}")
      template_href = template.ec2_ami
      templatestatus = @@config["iland_get_template_status"]
      templatestatuscmdLine = "java -cp #{@@apipath} #{templatestatus} #{@@configpath} #{template_href}"
      result = ""
      POpen4.popen4(templatestatuscmdLine) do |stdout, stderr, stdin, pid|
        status_err = stderr.read.strip
        status_out = stdout.read.strip
        if !status_err.include?("Exception") && status_out == "8"
          template.state = "available"
          template.save
          cmd.state = "Success"
          result = "8"
        else
          result = "0"
        end
        cmd.save
      end
      if result == "0" and template.created_at > Time.now - 60*60
        #If failed to get template for more than 30 minutes, skip it.
        next
      elsif result == "0" && template.created_at <= Time.now - 60*60
        #Get vpp status failed means the template Capturing failed
        job.state = 'Capturing Fail'
        job.save
        template.state = 'failed'
        template.save
        next
      end
    end
  end
  
  def self.capture_template
    joblist = Job.find(:all,:conditions => "state = 'Capturing' and region = 'iland'")
    joblist.each do |job|
      job = Job.find(job.id)
      if job.state != "Capturing"
        #Skip if the job state has been changed
        next
      end
      
      if job.is_busy == 1 && job.updated_at > Time.now - 5*60
        #Other thread running the commands in 5 minutes ago. Skip it
        next
      end
      job.is_busy = 1
      job.save
      job_id = job.id
      template = Template.find(:first,:conditions => "job_id = #{job_id}")
      cmdlist = Cmd.find(:all,:conditions => "job_id = #{job_id} and state = 'Pending'")
      cmdlist.each do |cmd|
        begin
          if cmd.state == 'Success'
            next
          end
          cmd.state = 'Running'
          cmd.save
          if cmd.command.include?("PowerOff")
            POpen4.popen4(cmd.command) do |stdout, stderr, stdin, pid|
              status_err = stderr.read.strip
              status_out = stdout.read.strip
              if !status_err.include?("Exception") && status_out=="true"
                cmd.state = "Success"
              else
                cmd.state = "Fail"
                cmd.error_log = status_err[status_err.length-255 , status_err.length-1]
              end
              cmd.save
            end
            break
          end
          if cmd.command.include?("GetVMStatus")
            POpen4.popen4(cmd.command) do |stdout, stderr, stdin, pid|
              status_err = stderr.read.strip
              status_out = stdout.read.strip
              if !status_err.include?("Exception")
                if status_out=="8"
                  cmd.state = "Success"
                  cmd.save
                end
              end
            end
            next
          end
          if cmd.command.include?("CaptureTemplate")
            POpen4.popen4(cmd.command) do |stdout, stderr, stdin, pid|
              status_err = stderr.read.strip
              status_out = stdout.read.strip
              if !status_err.include?("Exception") 
                cmd.state = "capturing"
                template.ec2_ami = status_out
                template.save
              else 
                cmd.state = "Fail"
                cmd.error_log = status_err[status_err.length-255 , status_err.length-1]
                job.state = "Capturing Fail"
                job.is_busy = 0
                job.save
              end
              cmd.save
            end
            break
          end
          if cmd.command.include?("PowerOn") && template.state == "available"
            POpen4.popen4(cmd.command) do |stdout, stderr, stdin, pid|
              status_err = stderr.read.strip
              status_out = stdout.read.strip
              if !status_err.include?("Exception") && status_out=="true"
                cmd.state = "Success"
                job.state = "Run"
                job.save
              else
                cmd.state = "Fail"
                cmd.error_log = status_err[status_err.length-255 , status_err.length-1]
              end
              cmd.save
            end
            break
          end
          if cmd.state == 'Running'
            cmd.state = 'Pending'
            cmd.save
          end
        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
        end
      end
    end
  end
  
  def self.recover_dead_iland_deployment
    ilandmachines = Ilandmachine.find(:all, :conditions => "instance_id is null or instance_id = ''")
    if ilandmachines.size != 0
      ilandmachines.each do |ilandmachine|
        if Time.now - ilandmachine.updated_at < 180
          next
        end
        active_ilandmachines = ActiveIlandmachine.find(:first, :conditions => "vapp_href = '#{ilandmachine.vapp_id}'")
        job = Job.find(:first, :conditions => "ilandmachine_id = #{ilandmachine.id}")
        if active_ilandmachines != nil
          ilandmachine.instance_id = active_ilandmachines.instance_id
          ilandmachine.public_dns = active_ilandmachines.public_dns
          ilandmachine.private_dns = active_ilandmachines.private_dns
          ilandmachine.status = 'Deployed'
          ilandmachine.save
          job.ilandmachine_id = ilandmachine.id
          job.state = "Run"
          job.save
          puts "Job recovered: " + job.id.to_s
        else
          dead_time = Time.now - job.updated_at
          if dead_time > 3600
            puts "Job keep deploying for too long time: " + job.id.to_s
            error_mail_sub = "Dead Deployment found"
            error_mail_content = "Dead Deployment found for: " + job.id.to_s
            Email.mail_to_admin(error_mail_sub, error_mail_content)
            falsetoprocess(job)
          elsif dead_time > 900 && dead_time <= 3600
            #If the command keep running for long time, re-run the command
            Cmd.recover_cmds(job)
          end
        end
      end
    end
  end
  
  def self.jobs_count(states = "('Deploying')")
    Job.find(:all, :conditions => "state in #{states} and (region != 'iland' or region is null)").size
  end

  def self.each_job(states = "('Deploying')") 
    index = 0
    pending_jobs_count = 0
  
    jobs = Job.find(:all, :conditions => "state in #{states} and (region != 'iland' or region is null)")
    jobs.each do |job|
      begin
        job = Job.find(job.id)
        if job.state == "Run"
          puts "Skip machine deployment, another task is running"
        next
        end
        pending_jobs_count = jobs_count("('Pending')")
        yield index, job, pending_jobs_count
        index = index + 1	
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
        falsetoprocess(job)
      end
    end  
  end
  {}
end
