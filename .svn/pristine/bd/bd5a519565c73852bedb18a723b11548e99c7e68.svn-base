class Ebsvolume < ActiveRecord::Base
#  validates_presence_of :manager_id, :message=>"selection is mandatory!!"
  belongs_to :user
  
  @@config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
  @@pk = @@config["ec2_bin_path"] + @@config["pk"]
  @@cert = @@config["ec2_bin_path"] + @@config["cert"]
  @@credential = " -K " + @@pk + " -C " + @@cert
  
  def can_access_ebsvolume(user)
    if self.user_id = user.id
      return true
    end
    return false
  end
  
  def self.delete(ebsvolume)
    command = @@config["ec2_bin_path"] + @@config["delete_ebs_volume"] + @@credential
    command = command + " --region " + ebsvolume.region
    command = command + " " +  ebsvolume.volume_id
    result = Cmd.run(command)
    ebsvolume.status = 'deleted'
    if result && result != "Fail"
      puts "Delete volume failed: " + command
    end
    ebsvolume.save    
    return result
  end
  
  def self.create(ebsvolume)
    command = @@config["ec2_bin_path"] + @@config["create_ebs_volume"] + @@credential
    command = command + " --region " + ebsvolume.region
    command = command + " -s " + ebsvolume.size.to_s if (ebsvolume.size && !ebsvolume.size.blank?)
    command = command + " -z " + ebsvolume.availabilityZone
    command = command + " --snapshot " + ebsvolume.snapshot_id if (ebsvolume.snapshot_id && !ebsvolume.snapshot_id.blank?)
    result = Cmd.run(command)
    ebsvolume.status = "pending"
    if result && result != "Fail"
      update(ebsvolume,result)        
    end      
    return result
  end
  
  def self.attach(ebsvolume)
    command = @@config["ec2_bin_path"] + @@config["ec2-attach-volume"] + @@credential
    command = command + " --region " + ebsvolume.region
    command = command + " -i " +  ebsvolume.instance_id
    command = command + " -d " +  ebsvolume.attach_device
    command = command + " " +  ebsvolume.volume_id
    result = Cmd.run(command)
    ebsvolume.status = "attaching"
    ebsvolume.save
    if !result || result == "Fail"
      puts "Attach volume failed: " + command
    end
    return result
  end

  def self.detach(ebsvolume)
    command = @@config["ec2_bin_path"] + @@config["ec2-detach-volume"] + @@credential
    command = command + " --region " + ebsvolume.region
    command = command + " -f " +  ebsvolume.volume_id
    result = Cmd.run(command)
    ebsvolume.status = "detaching"
    ebsvolume.save
    if !result || result == "Fail"
      puts "Detach volume failed: " + command
    end
    return result
  end  
  
  def self.update(volume, result)
    if result.include?("vol-") && result.include?('VOLUME')
       ## parse the resevation line
       record = result.split(" ")
       j = 0
       if !record[3].include?('snap-')
          j = -1
       end
       volume.volume_id = record[1]
       volume.save
      end   
  end
end