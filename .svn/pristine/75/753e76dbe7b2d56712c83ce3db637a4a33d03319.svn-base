class Elasticip < ActiveRecord::Base
  belongs_to :job
  belongs_to :user

  @@config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
  @@pk = @@config["ec2_bin_path"] + @@config["pk"]
  @@cert = @@config["ec2_bin_path"] + @@config["cert"]
  @@credential = " -K " + @@pk + " -C " + @@cert
  
  def self.create(elasticip)
    command = @@config["ec2_bin_path"] + @@config["ec2-allocate-address"] + @@credential
    command = command + " --region " + elasticip.region
    command = command + " -d vpc " if (elasticip.scope == "vpc")
    result = Cmd.run(command)
    puts command
    puts "-----------------------"
    puts result
    if result && result != "Fail"
      update(elasticip,result)        
    end      
    return result
  end
  
  def self.update(elasticip,result)
    if result.include?("ADDRESS")
       ## parse the line
       record = result.split(" ")
       j = 0
       elasticip.ip = record[1]
       if elasticip.scope == "vpc"
         elasticip.allocation_id = record[3]
       end
       elasticip.save
      end       
  end
  def can_access_elasticip(user)
    if self.user_id = user.id
      return true
    end
    return false
  end
  
  def self.delete(elasticip)
    command = @@config["ec2_bin_path"] + @@config["ec2-release-address"] + @@credential
    command = command + " --region " + elasticip.region
    if elasticip.scope != "vpc"
      command = command + " " + elasticip.ip
    else 
      command = command + " -a " + elasticip.allocation_id
    end
    
    result = Cmd.run_with_full_log(command)
    elasticip.deleted = 1
    if result[0] == "Exception" || (!result[2].blank? && !result[2].include?("Client.InvalidAddressID.NotFound"))
      puts "Delete IP failed: " + command
    else
      elasticip.save    
    end
    return result
  end

  def self.attach(elasticip)
    command = @@config["ec2_bin_path"] + @@config["ec2-associate-address"] + @@credential
    command = command + " --region " + elasticip.region
    if elasticip.scope != "vpc"
      command = command + " " + elasticip.ip
    else 
      command = command + " -a " + elasticip.allocation_id
    end   
    if elasticip.instance_id.blank?
      job = Job.find(elasticip.job_id)
      elasticip.instance_id = job.ec2machine.instance_id
    end
    command = command + " -i " +  elasticip.instance_id
    
    result = Cmd.run(command)
    
    if !result || result == "Fail"
      puts "Attach IP failed: " + command
      elasticip.instance_id = nil
      elasticip.save
    else
      if elasticip.job && elasticip.job.ec2machine
        elasticip.job.ec2machine.public_dns = elasticip.ip
        if elasticip.job.ec2machine.private_ip.blank?
          #if the machine is not initialized, re-get the machine info. 
          elasticip.job.ec2machine.public_dns = ""
          elasticip.job.ec2machine.public_ip = ""         
        end
        elasticip.job.ec2machine.save
      end
      if elasticip.scope == "vpc"
        records = result.split(" ")
        elasticip.associate_id = records[3]
        elasticip.save
      end
    end
    return result
  end

  def self.detach(elasticip)
    command = @@config["ec2_bin_path"] + @@config["ec2-disassociate-address"] + @@credential
    command = command + " --region " + elasticip.region
    if elasticip.scope != "vpc"
      command = command + " " + elasticip.ip
    else 
      command = command + " -a " + elasticip.associate_id
    end
    result = Cmd.run(command)
    if !result || result == "Fail"
      puts "Detach IP failed: " + command      
    else
      if elasticip.job && elasticip.job.ec2machine
        elasticip.job.ec2machine.public_dns = ""
        elasticip.job.ec2machine.save
      end
      elasticip.instance_id = nil
      elasticip.save
    end
    return result
  end  
  def is_attached
    if instance_id == nil
      return false
    else
      return true
    end
  end
end
