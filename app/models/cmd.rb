require 'popen4'
class Cmd < ActiveRecord::Base
  belongs_to :job
  
  @@config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
  @@pk = @@config["ec2_bin_path"] + @@config["pk"]
  @@cert = @@config["ec2_bin_path"] + @@config["cert"]
  @@credential = " -K " + @@pk + " -C " + @@cert
  
  def self.power_operation(job, ec2machine, operation, desciption)
    cmd = Cmd.new
    cmd.job_id = job.id
    cmd.state = "Pending"
    cmd.job_type = "P"
    cmd.created_at = Time.now
    cmd.updated_at = Time.now
    cmd.description = desciption
    
    powerCommand = @@config["ec2_bin_path"] + operation + @@credential
    powerCommand = powerCommand + " --region " + job.template.region
    powerCommand = powerCommand + " " + ec2machine.instance_id
    cmd.command = powerCommand
    cmd.save
    return cmd
  end
  
  def self.power_operation_iland(job, ilandmachine, operation, desciption)
    apipath = @@config["iland_api_jar_path"]
    configpath = @@config["iland_configuration_path"]
    cmd = Cmd.new
    cmd.job_id = job.id
    cmd.state = "Pending"
    cmd.job_type = "P"
    cmd.description = desciption
    herf = ilandmachine.vapp_id
    powerCommand = "java -cp #{apipath} #{operation} #{configpath} #{herf}"
    cmd.command = powerCommand
    cmd.save
    return cmd
  end
  
  def self.capture_template_iland_command(job, ilandmachine, template_name)
    apipath = @@config["iland_api_jar_path"]
    configpath = @@config["iland_configuration_path"]
    if job.state == "Run"
      capture_stop_machine_iland(job,ilandmachine)
    end
    cmd = Cmd.new()
    cmd.job_id = job.id
    cmd.state = "Pending"
    cmd.job_type = "P"
    cmd.description = "Capture template"
    capturetemplate = @@config["iland_capture_template"]
    vminstanceid = job.ilandmachine.instance_id
    command = "java -cp #{apipath} #{capturetemplate} #{configpath} #{template_name} #{vminstanceid}"
    cmd.command = command
    cmd.save
    #power on of vm
    capture_start_machine_iland(job,ilandmachine)
  end
  
  def self.capture_stop_machine_iland(job,ilandmachine)
    catpure_power_operation(job, ilandmachine, @@config["iland_stop_instances"], "Power OFF Of Iland")
  end
  
  def self.capture_start_machine_iland(job,ilandmachine)
    catpure_power_operation(job, ilandmachine, @@config["iland_start_instances"], "Power ON Of Iland")
  end
  
  def self.catpure_power_operation(job, ilandmachine, operation, desciption)
    apipath = @@config["iland_api_jar_path"]
    configpath = @@config["iland_configuration_path"]
    
    cmd = Cmd.new
    cmd.job_id = job.id
    cmd.state = "Pending"
    cmd.job_type = "P"
    cmd.description = desciption
    herf = ilandmachine.vapp_id
    powerCommand = "java -cp #{apipath} #{operation} #{configpath} #{herf}"
    cmd.command = powerCommand
    cmd.save
  end
  
  
  def self.port_operation(job, ec2machine, operation, port, desciption, source)
    cmd = Cmd.new
    cmd.job_id = job.id
    cmd.state = "Pending"
    cmd.job_type = "S"
    cmd.created_at = Time.now
    cmd.updated_at = Time.now
    cmd.description = desciption
    
    command = @@config["ec2_bin_path"] + operation + @@credential
    command = command + " --region " + job.template.region + " -P tcp -s #{source}" 
    command = command + " -p " + port 
    if ec2machine.sg_id
      command = command + " " + ec2machine.sg_id
    else
      command = command + " " + job.securitytype_name
    end
    cmd.command = command
    cmd.save
    return cmd  
  end
  
  def self.run_power_command(cmd)
    puts "Run Power command"
    state = run_cmd(cmd)
    if state != 'Fail'
      state = 'Success'
    end
    return state
  end
  
  def self.run_power_command_iland(cmd)
    puts "Run Power command for Iland machine"
    state = run_cmd_for_iland(cmd)
    if state != "Fail"&&state != "false"
      state = "Success"
    end
    return state
  end
  
  def self.run_port_command(cmd)
    puts "Run Port command"
    state = run_cmd(cmd)
    if state != 'Fail'
      state = 'Success'
    end
    return state
  end
  
  def self.run_newvapp_command_for_iland(cmd)
    puts "Run new vapp command for iland"
    state = run_cmd_for_iland(cmd)
    if state != 'Fail'
      return state
    end
    return "Fail"
  end
  
  def self.reboot_machine(job, ec2machine)
    return power_operation(job, ec2machine, @@config["ec2-reboot-instances"], "Reboot")
  end
  def self.reboot_machine_iland(job, ilandmachine)
    return reboot_operation_iland(job, ilandmachine, @@config["iland_reboot_instances"], "Reboot Iland")
  end
  def self.stop_machine(job, ec2machine)
    return power_operation(job, ec2machine, @@config["ec2-stop-instances"], "Power OFF" )
  end
  def self.stop_machine_iland(job, ilandmachine)
    return power_operation_iland(job, ilandmachine, @@config["iland_stop_instances"], "Power OFF iLand")
  end
  def self.daily_off_machine(job, ec2machine)
    return power_operation(job, ec2machine, @@config["ec2-stop-instances"], "Daily OFF" )
  end
  def self.high_network_off(job, ec2machine)
    return power_operation(job, ec2machine, @@config["ec2-stop-instances"], "Power OFF due to high network traffic" )
  end
  def self.low_cpu_off(job, ec2machine)
    return power_operation(job, ec2machine, @@config["ec2-stop-instances"], "Power OFF due to low CPU usage" )
  end
  def self.idle_off_machine(job, ec2machine)
    return power_operation(job, ec2machine, @@config["ec2-stop-instances"], "Idle OFF" )
  end   
  def self.daily_off_machine_iland(job, ilandmachine)
    return power_operation_iland(job, ilandmachine, @@config["iland_stop_instances"], "Daily OFF iLand")
  end
  def self.start_machine(job, ec2machine)
    return power_operation(job, ec2machine, @@config["ec2-start-instances"], "Power ON")
  end
  def self.start_machine_iland(job, ilandmachine)
    return power_operation_iland(job, ilandmachine, @@config["iland_start_instances"], "Power ON iLand")
  end
  
  def self.reboot_operation_iland(job, ilandmachine, operation ,desciption)
    apipath = @@config["iland_api_jar_path"]
    configpath = @@config["iland_configuration_path"]
    rebootcmd = Cmd.new()
    rebootcmd.job_id = job.id
    rebootcmd.state = "Pending"
    rebootcmd.job_type = "P"
    rebootcmd.description = "Reboot VM"
    vminstanceid = ilandmachine.instance_id
    command = "java -cp #{apipath} #{operation} #{configpath} #{vminstanceid}"
    rebootcmd.command = command
    rebootcmd.save
    return rebootcmd
  end
  
  def self.open_port(job, ec2machine, port, source)
    if port == "RDP"
      return port_operation(job, ec2machine, @@config["change_group_port"], '3389', "Add Security Group protocol tcp Port 3389 Source #{source}", source)
    elsif port== "VNC"
      return port_operation(job, ec2machine, @@config["change_group_port"], '5900-5901', "Add Security Group protocol tcp Port 5900-5901 Source #{source}", source)
    elsif port == "SSH"
      return port_operation(job, ec2machine, @@config["change_group_port"], '22-22', "Add Security Group protocol tcp Port 22-22 Source #{source}", source)
    else
      return nil
    end
  end
  def self.close_port(job, ec2machine, port)
    if port == "RDP"
      return port_operation(job, ec2machine, @@config["ec2-revoke"], '3389', "Remove Security Group protocol tcp Port 3389 Source 0.0.0.0/0", "0.0.0.0/0")
    elsif port== "VNC"
      return port_operation(job, ec2machine, @@config["ec2-revoke"], '5900-5901', "Add Security Group protocol tcp Port 5900-5901 Source 0.0.0.0/0", "0.0.0.0/0")
    elsif port == "SSH"
      return port_operation(job, ec2machine, @@config["ec2-revoke"], '22-22', "Add Security Group protocol tcp Port 22-22 Source 0.0.0.0/0", "0.0.0.0/0")
    else
      return nil
    end  
  end
  
  def self.run_cmd(cmd)
    begin
      std_out = ""
      POpen4.popen4(cmd.command) do |stdout, stderr, stdin, pid|
        status_err = stderr.read.strip
        if status_err != nil && status_err != ""  
          if status_err.include?("Client.InvalidPermission.Duplicate")
            #Accept the duplicate error
            cmd.state = "Success"
          else 
            cmd.state = "Fail"
            puts "Run cmd " + cmd.description + " failed: " + status_err
          end
        else 
          cmd.state = "Success"
          std_out = stdout.read.strip
        end
      end
      cmd.updated_at = Time.now
      cmd.save
      if cmd.state == "Fail"
        return cmd.state
      else
        return std_out
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
      cmd.state = "Fail"
      cmd.updated_at = Time.now
      cmd.save
      return cmd.state
    end
  end
  
  def self.run_cmd_for_iland(cmd)
    begin
      std_out = ""
      POpen4.popen4(cmd.command) do |stdout, stderr, stdin, pid|
        status_err = stderr.read.strip
        if !status_err.include?("Exception")
          cmd.state = "Success"
          std_out = stdout.read.strip
        else 
          cmd.state = "Fail"
          cmd.error_log = status_err[status_err.length-5120 , status_err.length-1]
          puts "Run cmd " + cmd.description + " failed: " + status_err
        end
      end
      cmd.updated_at = Time.now
      cmd.save
      if cmd.state == "Fail"
        return cmd.state
      else
        return std_out
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
      cmd.state = "Fail"
      cmd.updated_at = Time.now
      cmd.save
      return cmd.state
    end
  end
  
  def self.run(command)
    state = ""
    begin
      std_out = ""
      POpen4.popen4(command) do |stdout, stderr, stdin, pid|
        status_err = stderr.read.strip
        if status_err != nil && status_err != ""                
          state = "Fail"
          puts "Run Command " + command + " failed: " + status_err
        else 
          state = "Success"
          std_out = stdout.read.strip
        end
      end
      if state == "Fail"
        return state
      else
        return std_out
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
      state = "Fail"
      return state
    end
  end
  
  def self.run_with_full_log(command)
    result = Array.new
    begin
      POpen4.popen4(command) do |stdout, stderr, stdin, pid|
        result[0] = "Run"
        result[1] = stdout.read
        result[2] = stderr.read
        result[3] = stdin
        result[4] = pid
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
      result[0] = "Exception"
    end
    return result
  end 
  
  def self.recover_cmds(job)
    cmds = Cmd.find(:all, :conditions => "job_id = #{job.id} and state='Running'")
    cmds.each do |cmd|
      cmd.state = 'Pending'
      cmd.save    
    end   
  end
end