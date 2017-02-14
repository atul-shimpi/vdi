require 'rubygems'
require 'yaml'

# The ruby task will crash easily. So lots of long interval tasks failed to run in 
# ruby task. This file is supposed to add as system cron, and run it in hourly.
RAILS_ENV = 'production'
RAILS_ROOT = File.join(File.dirname(File.expand_path(__FILE__)), '..')
Dir.chdir(RAILS_ROOT)
require File.join('config', 'environment')
@@config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
@@pk = @@config["ec2_bin_path"] + @@config["pk"]
@@cert = @@config["ec2_bin_path"] + @@config["cert"]

def get_images_by_region(region)
  begin
    get_all_images_cmd = @@config["ec2_bin_path"] + @@config["get_ami_command"] + " -C " + @@cert + " -K " + @@pk + ' --region ' + region + " --request-timeout 30"
    strs = IO.popen(get_all_images_cmd)
    sleep(1)
    i = 0
    lines = Array.new
    while line=strs.gets
          lines[i] = line
          i = i + 1          
    end
    if lines.length >= 1
      #ActiveRecord::Base.connection.execute("delete from active_machines")
      i = 0
      while i < lines.length - 1
        if lines[i].include?("ami-") 
          ## parse the reservation line
          record = lines[i].split(" ")
          ami = ActiveAmi.new()
          ami.ami_id = record[1]
          j = 0
          ami.name = record[2]
          while j < record.size - 9
            state = (record[4 + j]).strip
            if state != 'available' && state != 'pending' && state!= 'deleted'
              j = j + 1
              ami.name = ami.name + record[2 + j]
            else
              break
            end
          end
          if j > record.size - 9
            puts lines[i]
            next
          end
          ami.imageState = record[4 + j]
          if record[4 + j] != 'available'
            puts lines[i]
          end
          ami.architecture = record[6 + j]
          if record[8 + j] == 'windows'
             ami.platform = record[8 + j]
          else
             ami.platform = 'linux'
          end
          ami.region = region
          ami.save
        end   
        i = i + 1
      end
    end
  rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
  end    
end

def update_all_images
  ActiveRecord::Base.connection.execute("delete from active_amis")
  regions = @@config["regions"].split(",")
  for region in regions
    get_images_by_region(region.strip)
  end
end

def get_snapshots_by_region(region)
  begin
    get_all_snapshots_cmd = @@config["ec2_bin_path"] + @@config["get_snapshot_command"] + " -C " + @@cert + " -K " + @@pk + ' --region ' + region + " --request-timeout 30"
    strs = IO.popen(get_all_snapshots_cmd)
    sleep(1)
    i = 0
    lines = Array.new
    while line=strs.gets
          lines[i] = line
          i = i + 1
    end
    if lines.length >= 1
      #ActiveRecord::Base.connection.execute("delete from active_machines")
      i = 0
      while i < lines.length - 1
        if lines[i].include?("snap-") 
          ## parse the resevation line
          record = lines[i].split(" ")
          snapshot = ActiveSnapshot.new()
          snapshot.snapshot_id = record[1]
          snapshot.volume_id = record[2]
          snapshot.status = record[3]
          snapshot.start_at = record[4]
          snapshot.volumeSize = record[7]
          snapshot.region = region
          amis = lines[i].scan(/ami-[0-9a-z]*/)
          if amis.size>=1
              snapshot.ami = amis[0]
          end
          snapshot.save
        end   
        i = i + 1
      end
    end
  rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
  end    
end

def get_all_snapshots
  ActiveRecord::Base.connection.execute("delete from active_snapshots")
  regions = @@config["regions"].split(",")
  for region in regions
    get_snapshots_by_region(region.strip)
  end
end

def get_volumes_by_region(region)
  begin
    get_all_snapshots_cmd = @@config["ec2_bin_path"] + @@config["get_volume_command"] + " -C " + @@cert + " -K " + @@pk + ' --region ' + region + " --request-timeout 30"
    strs = IO.popen(get_all_snapshots_cmd)
    sleep(1)
    i = 0
    lines = Array.new
    while line=strs.gets
          lines[i] = line
          i = i + 1
    end
    if lines.length >= 1
      ActiveRecord::Base.connection.execute("delete from active_volumes where region = '#{region}'")
      i = 0
      while i < lines.length - 1
        if lines[i].include?("vol-") && lines[i].include?('VOLUME')
          ## parse the resevation line
          record = lines[i].split(" ")
          volume = ActiveVolume.new()
          volume.volume_id = record[1]
          volume.size = record[2]
          volume.snapshot_id = record[3]
          j = 0
          if !record[3].include?('snap-')
            j = -1
          end
          volume.availabilityZone = record[4 + j]
          volume.status = record[5 + j]
          if record[5 + j] != 'in-use' && record[5 + j] != 'available' && record[5 + j] != 'deleting'
            puts lines[i]
          end
          volume.region = region
          volume.createTime = record[6]
          if lines[i + 1].include?('ATTACHMENT')
            record1 = lines[i + 1].split(" ")
            if record1[1] == record[1]
              volume.instance_id = record1[2]
              volume.attach_device = record1[3]              
            end
            i = i + 1
          end
          volume.save
        end   
        i = i + 1
      end
    end
  rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
  end    
end

def get_all_volumes
  #ActiveRecord::Base.connection.execute("delete from active_volumes")
  regions = @@config["regions"].split(",")
  for region in regions
    get_volumes_by_region(region.strip)
  end
end

def clean_up_dead_ebs
  sql = "select av.*
         from
           (select * from active_volumes where status = 'available') as av
         left join  active_snapshots ass
           on av.snapshot_id = ass.snapshot_id
         where ass.ami is not null and deleted != 1 limit 300"
  dead_ebs = ActiveVolume.find_by_sql(sql)
  if dead_ebs.size() > 0
    dead_ebs.each do |ebs|
      begin
        cmd = @@config["ec2_bin_path"] + @@config["delete_ebs_volume"] + " -C " + @@cert + " -K " + @@pk + ' --region ' + ebs.region + " " + ebs.volume_id
        puts "removing: " + ebs.volume_id
        IO.popen(cmd)
        ebs.deleted = 1
        ebs.save
        sleep(10)
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end   
    end    
  end
end

def get_elasticip_by_region(region)
  begin
    get_all_elasticip_cmd = @@config["ec2_bin_path"] + @@config["ec2-describe-addresses"] + " -C " + @@cert + " -K " + @@pk + ' --region ' + region + " --request-timeout 30"
    strs = IO.popen(get_all_elasticip_cmd)
    sleep(1)
    i = 0
    lines = Array.new
    while line=strs.gets
          lines[i] = line
          i = i + 1
    end
    if lines.length >= 1
      i = 0
      while i < lines.length - 1
        if lines[i].include?("ADDRESS")
          ## parse the resevation line
          record = lines[i].split("\x09")
          ip = ActiveIp.new()
          ip.ip = record[1]
          ip.instance_id = record[2]
          ip.scope = record[3]
          ip.alloc = record[4]
          ip.assoc = record[5]
          ip.region = region
          ip.save
        end   
        i = i + 1
      end
    end
  rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
  end    
end

def get_all_ips
  ActiveRecord::Base.connection.execute("delete from active_ips")
  regions = @@config["regions"].split(",")
  for region in regions
    get_elasticip_by_region(region.strip)
  end
end

def clean_dead_elsatic_ip
  sql = "select ai.*, ei.id as eid
         from active_ips ai
         left join elasticips ei
         on ai.alloc = ei.allocation_id
         left join jobs j
         on j.id = ei.job_id
         where ai.scope = 'vpc' and (ai.instance_id = '' or ai.instance_id is null) and (j.state is null or j.state in ('Run', 'Build Fail', 'Undeploy', 'Expired'))"
  ips = ActiveIp.find_by_sql(sql)
  for ip in ips
    begin
      delete_ip_command = @@config["ec2_bin_path"] + @@config["ec2-release-address"] + " -C " + @@cert + " -K " + @@pk + " --request-timeout 30"      
      delete_ip_command += " --region " + ip.region + " -a " + ip.alloc
      puts "removing dead ip: " + ip.alloc.to_s
      IO.popen(delete_ip_command)
      sleep(3)
      if ip[:eid] 
        eip = Elasticip.find(ip[:eid])
        eip.deleted = 1
        eip.save
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end 
  end
end

update_all_images
get_all_snapshots
get_all_volumes
clean_up_dead_ebs
get_all_ips
clean_dead_elsatic_ip