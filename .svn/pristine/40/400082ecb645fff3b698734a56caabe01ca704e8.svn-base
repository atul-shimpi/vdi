class Snapshot < ActiveRecord::Base
#  validates_presence_of :manager_id, :message=>"selection is mandatory!!"
  belongs_to :user

  @@config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
  @@pk = @@config["ec2_bin_path"] + @@config["pk"]
  @@cert = @@config["ec2_bin_path"] + @@config["cert"]
  @@credential = " -K " + @@pk + " -C " + @@cert
  
  def can_access_snapshot(user)
    if self.user_id = user.id
      return true
    end
    return false
  end
  def self.delete(snapshot)
    command = @@config["ec2_bin_path"] + @@config["delete_snapshot"] + @@credential
    command = command + " --region " + snapshot.region
    command = command + " " +  snapshot.snapshot_id
    result = Cmd.run(command)
    snapshot.status = 'deleted'
    if result && result != "Fail"
      puts "Delete snapshot failed: " + command
    end
    snapshot.save    
    return result    
  end
  
  def self.create(snapshot)
    command = @@config["ec2_bin_path"] + @@config["create_snapshot"] + @@credential
    command = command + " --region " + snapshot.region
    command = command + " -d " + snapshot.name.gsub(/\W/,'')
    command = command + " " + snapshot.volume_id

    
    result = Cmd.run(command)
    snapshot.status = "pending"
    if result && result != "Fail"
      update(snapshot,result)        
    end      
    return result
  end 
  
  def self.update(snapshot, result)
    if result.include?("snap-")
       ## parse the resevation line
       record = result.split(" ")
       snapshot.snapshot_id = record[1]
       snapshot.status = record[3]
       snapshot.size = record[7]
       snapshot.save
    end 
  endend