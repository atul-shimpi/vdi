class Runcluster < ActiveRecord::Base
  belongs_to :cluster
  has_many :jobs
  belongs_to :user 
   
  def can_access(user)
    if user.is_external && self.user_id != user.id
      return false
    end
    return true
  end 

  def deploy(clusters, user)
    deploy_cluster_with_commands(clusters, user, nil)
  end

  def deploy_cluster_with_commands(clusters, user, initcmds)
    self.name = clusters.name
    self.description = clusters.description
    self.cluster_id = clusters.id
    self.state = "actives"
    self.user_id = user.id
    self.save
    locks = Lock.find(:all,:conditions => ['cluster_id = ?',clusters.id])
    clusterconfiguration = Clusterconfiguration.find(:all,:conditions => ['cluster_id = ?',clusters.id])
    clusterconfiguration.each do |c|
      configuration = Configuration.find(c.configuration_id)
      job = Job.new
      if !initcmds.blank?
        configuration.init_commands = intert_gbuild_commands(configuration.init_commands, initcmds)
        job.usage = "VDIBuild"
      end
      job.runcluster_id = self.id
      job.role = c.role
      Job.deployjobfromconf(job,configuration, user)
      Configuration.add_userdata_as_commands(job,configuration)
      if locks != nil
        locks.each do |lock|
          clusterlock = Clusterlock.new
          clusterlock.runcluster_id = self.id
          clusterlock.job_id = job.id
          clusterlock.lock_id = lock.id
          clusterlock.lock_status = "lock"
          clusterlock.save
        end
      end
    end
  end
  
  def intert_gbuild_commands(init_cmds, gbuild_commands)
    return init_cmds.gsub('$GBUILD_INIT_COMMANDS', gbuild_commands)  
  end
end