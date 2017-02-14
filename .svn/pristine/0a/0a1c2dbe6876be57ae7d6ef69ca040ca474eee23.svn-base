class ClustersController < ApplicationController
  layout "application",:except=>[:webserviceDeploycluster, :webserviceUndeploycluster, :checklock, :updatelock, :rolemapping, :set_param, :get_param]
  @@config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
  @@verify = @@config["verify"]
  def index
    if current_user.is_external
      @clusters = Cluster.find(:all, :conditions => "state = 'available' and user_id = #{current_user.id}", :order=>"id desc")
    else
      @clusters = Cluster.find(:all, :conditions => ['state = ?',"available"], :order=>"id desc")
    end
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @clusters = @clusters.paginate  :page => params[:page],:per_page => per_page
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @clusters }
    end
  end
  
  def actives
    if current_user.is_external
      @clusters = Runcluster.find(:all, :conditions => "state = 'actives' and user_id = #{current_user.id}", :order=>"id desc")
    else
      @clusters = Runcluster.find(:all, :conditions => ['state = ?',"actives"], :order=>"id desc")
    end
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @clusters = @clusters.paginate  :page => params[:page],:per_page => per_page
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @clusters }
    end
  end
  
  def history
    if current_user.is_external
      @clusters = Runcluster.find(:all, :conditions => "state = 'history' and user_id = #{current_user.id}", :order=>"id desc")
    else    
      @clusters = Runcluster.find(:all, :conditions => ['state = ?', "history"], :order=>"id desc")
    end
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @clusters = @clusters.paginate  :page => params[:page],:per_page => per_page
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @clusters }
    end
  end
  
  def new
    @clusters = Cluster.new
    if current_user.is_external
      @configurations = Configuration.find(:all, :conditions => "deleted = 0 and user_id = #{current_user.id}") 
    else  
      @configurations = Configuration.find(:all, :conditions => ['deleted = ?', 0])   
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @clusters }
    end
  end
  
  def create
    count = params[:counttemp].to_i
    lockcount = params[:lockcounttemp].to_i
    @clusters = Cluster.new()
    @clusters.name = params[:name]
    if current_user.is_external
      @configurations = Configuration.find(:all, :conditions => "deleted = 0 and user_id = #{current_user.id}") 
    else  
      @configurations = Configuration.find(:all, :conditions => ['deleted = ?', 0])   
    end
    if @clusters.name == nil || @clusters.name == ""
      respond_to do |format|
        flash[:notice] = 'Please input cluster configuration name'
        format.html { render :action => "new" }
        format.xml  { render :xml => @clusters.errors, :status => :unprocessable_entity }
      end
    elsif
    @clusters.description = params[:description]
    @clusters.state = "available"
    @clusters.user_id = current_user.id
    @clusters.save
    
    for j in (1..lockcount)
      lock = "lock" + j.to_s
      locktemp = params[lock]
      if locktemp != "" && locktemp != nil
        @lock = Lock.new
        @lock.cluster_id = @clusters.id
        @lock.name = locktemp
        @lock.save
      end
    end
    
    for i in (1..count)
      con = "configurations" + i.to_s
      role = "role" + i.to_s
      role_temp = params[role]
      temp = params[con]
      if temp != "" && temp != nil
        @clusterconfiguration = Clusterconfiguration.new
        @clusterconfiguration.cluster_id = @clusters.id
        @clusterconfiguration.configuration_id = temp
        @clusterconfiguration.role = role_temp
        @clusterconfiguration.save
      end
    end
    
    respond_to do |format|
      flash[:notice] = 'Cluster was successfully created.'
      format.html { redirect_to :action => "show", :id => @clusters.id }
      format.xml  { render :xml => @clusters, :status => :created, :location => @clusters }
    end
    end
  end
  
  def show
    url = request.request_uri
    uri = URI.parse(url)  
    query_params = uri.query
    if query_params != nil
      if query_params.include?"clustername"
        if uri.to_s.include?"webserviceDeploycluster"
          webserviceDeploycluster
        else
          webserviceUndeploycluster
        end
      end
    else
      @clusters = Cluster.find(params[:id])
      if @clusters.state == 'Delete' && !current_user.is_admin
        flash[:notice] = 'The cluster has been removed.'
        redirect_to :action=>"index"
        return
      end
      
      if !@clusters.can_access(current_user)
        flash[:notice] = 'You have no permission to access this cluster'
        redirect_to :action => 'welcome',:controller=>'users'
        return        
      end
      
      @locks = Lock.find(:all, :conditions => ['cluster_id = ?',@clusters.id])
      @clusterconfiguration = Clusterconfiguration.find(:all,:conditions => ['cluster_id = ?',@clusters.id])
      @configurations = Array.new
      @role = Array.new
      count = 0
      @clusterconfiguration.each do |c|
        @configurations[count] = Configuration.find(c.configuration_id)
        @role[count] = c.role
        count = count + 1
      end
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @clusters }
      end
    end
  end
  
  def edit
    @clusters = Cluster.find(params[:id])
    if !@clusters.can_access(current_user)
      flash[:notice] = 'You have no permission to access this cluster'
      redirect_to :action => 'welcome',:controller=>'users'
      return        
    end    
    @locks = Lock.find(:all, :conditions => ['cluster_id = ?',@clusters.id])
    @clusters_id = @clusters.id
    
    @locksize = @locks.size
    @locktempcount = Array.new(@locksize)
    @lockchoosed = Array.new(@locksize)
    @lockcount = 0
    @locks.each do |lock|
      @lockchoosed[@lockcount] = lock.name
      @lockcount = @lockcount + 1
    end
    
    @clusterconfiguration = Clusterconfiguration.find(:all,:conditions => ['cluster_id = ?',@clusters.id])
    if current_user.is_external
      @configurations = Configuration.find(:all, :conditions => "deleted = 0 and user_id = #{current_user.id}") 
    else  
      @configurations = Configuration.find(:all, :conditions => ['deleted = ?', 0])   
    end
    
    tempcount = @clusterconfiguration.size
    @size = tempcount.to_i
    @tempcount = Array.new(tempcount)
    @choosed = Array.new(tempcount)
    @rolechoosed = Array.new(tempcount)
    @count = 0
    @clusterconfiguration.each do |c|
      @choosed[@count] = Configuration.find(c.configuration_id).id
      @rolechoosed[@count] = c.role
      @count = @count + 1
    end
    for i in (@count..tempcount)
      @choosed[i] = 0
      @rolechoosed[i] = ""
    end
  end
  
  def update
    count = params[:counttemp].to_i
    lockcount = params[:lockcounttemp].to_i
    @clusters = Cluster.find(params[:id])
    if !@clusters.can_access(current_user)
      flash[:notice] = 'You have no permission to access this cluster'
      redirect_to :action => 'welcome',:controller=>'users'
      return        
    end  
    
    @clusters.name = params[:name]
    @clusters.description = params[:description]
    @clusters.state = "available"
    @clusters.save
    
    @locks = Lock.find(:all, :conditions => ['cluster_id = ?',@clusters.id])
    @lockcount = 0
    @locks.each do |lock|
      lockchoosed = "lock" + @lockcount.to_s
      if params[lockchoosed] != nil && params[lockchoosed] != ""
        lock.name = params[lockchoosed]
        lock.save
      else
        lock.destroy
      end
      @lockcount = @lockcount + 1
    end
    for j in (@lockcount..lockcount)
      lockchoosed = "lock" + j.to_s
      if params[lockchoosed] != nil && params[lockchoosed] != ""
        lock = Lock.new
        lock.name = params[lockchoosed]
        lock.cluster_id = @clusters.id
        lock.save
      end
    end
    
    @clusterconfiguration = Clusterconfiguration.find(:all,:conditions => ['cluster_id = ?',@clusters.id])
    @count = 0
    @clusterconfiguration.each do |c|
      con = "configurations" + @count.to_s
      role = "role" + @count.to_s
      if params[con] != nil && params[con] != ""
        c.configuration_id = params[con]
        c.role = params[role]
        c.save
      else
        c.destroy
      end
      @count = @count + 1
    end
    for i in (@count..count)
      con = "configurations" + i.to_s
      role = "role" + i.to_s
      role_temp = params[role]
      temp = params[con]
      if temp != "" && temp != nil
        @clusterconfiguration = Clusterconfiguration.new
        @clusterconfiguration.cluster_id = @clusters.id
        @clusterconfiguration.configuration_id = temp
        @clusterconfiguration.role = role_temp
        @clusterconfiguration.save
      end
    end
    respond_to do |format|
      if @clusters.update_attributes(params[:template])
        flash[:notice] = 'Clusterconfiguration was successfully updated.'
        format.html { redirect_to :action => "show", :id => @clusters.id }
        format.xml  { render :xml => @clusters, :status => :created, :location => @clusters }
      end
    end
  end
  
  def destroy
    @clusters = Cluster.find(params[:id])
    if !@clusters.can_access(current_user)
      flash[:notice] = 'You have no permission to access this cluster'
      redirect_to :action => 'welcome',:controller=>'users'
      return        
    end      
    @clusters.state = "Delete"
    @clusters.save
    respond_to do |format|
      format.html { redirect_to(clusters_url) }
      format.xml  { head :ok }
    end
  end
  
  def deploycluster
    clusters = Cluster.find(params[:id])
    if clusters.state == 'Delete' && !current_user.is_admin
        flash[:notice] = 'The cluster has been removed.'
        redirect_to :action=>"index"
        return
    end
    if !clusters.can_access(current_user)
      flash[:notice] = 'You have no permission to access this cluster'
      redirect_to :action => 'welcome',:controller=>'users'
      return        
    end  
    run_cluster = Runcluster.new
    run_cluster.deploy(clusters, current_user)
    respond_to do |format|
      format.html { redirect_to :action => "showruncluster", :id => run_cluster.id, :controller=>"clusters" }
      format.xml  { render :xml => run_cluster }
    end
  end
  
  def showruncluster
    @run_cluster = Runcluster.find(params[:id])
    if !@run_cluster.can_access(current_user)
      flash[:notice] = 'You have no permission to access this cluster'
      redirect_to :action => 'welcome',:controller=>'users'
      return        
    end      
    @locks = Lock.find(:all, :conditions => ['cluster_id = ?',@run_cluster.cluster_id])
    @jobs = Job.find(:all,:conditions => ['runcluster_id = ?',@run_cluster.id])
    count = 0
    @ec2machine = Array.new
    @user = Array.new
    @password = Array.new
    @jobs.each do |job|
      if job.ec2machine_id == nil
        @ec2machine[count] == nil
      else
        @ec2machine[count] = Ec2machine.find(job.ec2machine_id)
      end
      @user[count] = Template.find(job.template_id).user
      @password[count] = Template.find(job.template_id).password
      count = count + 1
    end
    lockcount = 0
    @lockstatus = Array.new
    @locks.each do |lock|
      clusterlocks = Clusterlock.find(:all,:conditions => ['lock_id = ? and runcluster_id = ?',lock.id, @run_cluster.id])
      @lockstatus[lockcount] = "unlock"
      clusterlocks.each do |c|
        if c.lock_status == "lock"
          @lockstatus[lockcount] = "lock"
        end
      end
      lockcount = lockcount + 1
     end
    
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @run_cluster }
    end
  end
  
  def editruncluster
    @run_cluster = Runcluster.find(params[:id])
    if !@run_cluster.can_access(current_user)
      flash[:notice] = 'You have no permission to access this cluster'
      redirect_to :action => 'welcome',:controller=>'users'
      return        
    end        
    @run_cluster_id = @run_cluster.id
  end
  
  def updateruncluster
    @run_cluster = Runcluster.find(params[:id])
    if !@run_cluster.can_access(current_user)
      flash[:notice] = 'You have no permission to access this cluster'
      redirect_to :action => 'welcome',:controller=>'users'
      return        
    end        
    @run_cluster.name = params[:clustersname]
    @run_cluster.description = params[:description]
    @run_cluster.save
    respond_to do |format|
      format.html { redirect_to :action => "showruncluster", :id => @run_cluster.id, :controller=>"clusters" }
      format.xml  { render :xml => @run_cluster }
    end
  end
  
  def deleteruncluster
    @run_cluster = Runcluster.find(params[:id])
    if !@run_cluster.can_access(current_user)
      flash[:notice] = 'You have no permission to access this cluster'
      redirect_to :action => 'welcome',:controller=>'users'
      return        
    end        
    undeploy(@run_cluster)
    respond_to do |format|
      format.html { redirect_to :action => "showruncluster", :id => @run_cluster.id, :controller=>"clusters" }
      format.xml  { render :xml => @run_cluster }
    end
  end
  
  def undeploy(run_cluster)
    run_cluster.state = "history"
    run_cluster.save
    jobs = Job.find(:all,:conditions => ['runcluster_id = ?',run_cluster.id])
    jobs.each do |job|
      job.deletejob(job) 
    end
  end
  
  def stop
    @run_cluster = Runcluster.find(params[:id])
    if !@run_cluster.can_access(current_user)
      flash[:notice] = 'You have no permission to access this cluster'
      redirect_to :action => 'welcome',:controller=>'users'
      return        
    end        
    @jobs = Job.find(:all,:conditions => ['runcluster_id = ?',@run_cluster.id])
    @jobs.each do |job|
      if !job.can_write_job(current_user)
        flash[:notice] = 'You have no permission to visit this page '
        redirect_to :action => 'welcome',:controller=>'users'
      end
      job.power_off
    end
    redirect_to :action => "showruncluster", :id => @run_cluster.id
  end
  
  def start
    @run_cluster = Runcluster.find(params[:id])
    if !@run_cluster.can_access(current_user)
      flash[:notice] = 'You have no permission to access this cluster'
      redirect_to :action => 'welcome',:controller=>'users'
      return        
    end        
    @jobs = Job.find(:all,:conditions => ['runcluster_id = ?',@run_cluster.id])
    @jobs.each do |job|
      if !job.can_write_job(current_user)
        flash[:notice] = 'You have no permission to visit this page '
        redirect_to :action => 'welcome',:controller=>'users'
      end 
      job.power_on
    end
    redirect_to :action => "showruncluster", :id => @run_cluster.id
  end
  
  def webserviceDeploycluster
    url = request.request_uri
    uri = URI.parse(url)  
    query_params = uri.query
    clusters = ""
    clustername = ""
    if query_params != nil
      if query_params.include?"clustername"
        clustername = params[:clustername]
        clusters =  Cluster.find(:first, :conditions => ["name = :clustername and state = 'available'", {:clustername => clustername}])
      end
    else
      clusters =  Cluster.find_by_id(params[:id])
    end
    if clusters != nil
      @run_cluster = Runcluster.new
      @run_cluster.deploy(clusters,current_user)
      respond_to do |format|
        format.html
        format.xml  { head :ok }
      end
    else
      respond_to do |format|
        format.html
        format.xml  { head :ok }
      end
    end
  end
  
  def webserviceUndeploycluster
    url = request.request_uri
    uri = URI.parse(url)  
    query_params = uri.query
    @clusters = ""
    clustername = ""
    if query_params != nil
      if query_params.include?"clustername"
        clustername = params[:clustername]
        @clusters =  Runcluster.find(:all, :conditions => ["name = :clustername and state = 'actives'", {:clustername => clustername}])
        if @clusters != nil && @clusters.size != 0
          @clusters.each do |cluster|
            undeploy(cluster)
          end
        end
        respond_to do |format|
          format.html
          format.xml  { head :ok }
        end
      end
    else
      @clusters =  Runcluster.find(:all, :conditions => ["id = ? and state = 'actives'", params[:id]])
      if @clusters != nil && @clusters.size != 0
        @clusters.each do |c|
          undeploy(c)
        end
      end
      respond_to do |format|
        format.html
        format.xml  { head :ok }
      end
    end
  end

  def checklock
    if current_user != nil
      @verify = @@verify
    else
      @verify = params[:verify]
    end
    if @verify != nil && @verify == @@verify
    url = request.request_uri
    uri = URI.parse(url)  
    query_params = uri.query
    instanceid = params[:instanceid]
    lockname = params[:lockname]
    if query_params != nil
      @lockstatus = "unlock"
      @lock = ""
      if instanceid != nil && lockname != nil
        @ec2machine = Ec2machine.find_by_instance_id(instanceid)
        if @ec2machine != nil
          @job = Job.find_by_ec2machine_id(@ec2machine.id)
          if @job.runcluster_id != nil
            runcluster = Runcluster.find(@job.runcluster_id)
            @lock = Lock.find_by_cluster_id_and_name(runcluster.cluster_id,lockname)
            if @lock != nil
              @clusterlocks = Clusterlock.find(:all,:conditions => ["runcluster_id = ? and lock_id = ?",runcluster.id,@lock.id])
              if @clusterlocks != nil
                @clusterlocks.each do |c|
                  if c.lock_status == "lock"
                    @lockstatus = "lock"
                  end
                end
              end
            end
          end
        end
      else
        if instanceid != nil
          @ec2machine = Ec2machine.find_by_instance_id(instanceid)
          if @ec2machine != nil
            @job = Job.find_by_ec2machine_id(@ec2machine.id)
            if @job.runcluster_id != nil
            runcluster = Runcluster.find(@job.runcluster_id)
            p runcluster.id
            @clusterlocks = Clusterlock.find(:all,:conditions => ["runcluster_id = ? ",runcluster.id])
            if @clusterlocks != nil
              @clusterlocks.each do |c|
                if c.lock_status == "lock"
                  @lockstatus = "lock"
                end
              end
            end
            end
          end
        end
      end
    end
    else
      @verify = nil
    end
    respond_to do |format|
      format.html
      format.xml  { head :ok }
    end
  end
  
  def updatelock
    if current_user != nil
      @verify = @@verify
    else
      @verify = params[:verify]
    end
    if @verify != nil && @verify == @@verify
    url = request.request_uri
    uri = URI.parse(url)  
    query_params = uri.query
    instanceid = params[:instanceid]
    lockname = params[:lockname]
    if query_params != nil
      if instanceid != nil && lockname != nil
        @ec2machine = Ec2machine.find_by_instance_id(instanceid)
        @job = Job.find_by_ec2machine_id(@ec2machine.id)
        if @job.runcluster_id != nil
        runcluster = Runcluster.find(@job.runcluster_id)
        @lock = Lock.find_by_cluster_id_and_name(runcluster.cluster_id,lockname)
        if @lock != nil
          @clusterlock = Clusterlock.find_by_job_id_and_lock_id(@job.id,@lock.id)
          if @clusterlock != nil
            @clusterlock.lock_status = "unlock"
            @clusterlock.save
            @return = "success"
          end
        end
        end
      end
    end
    else
      @verify = nil
    end
    respond_to do |format|
      format.html
      format.xml  { head :ok }
    end
  end
  
  def rolemapping
    if current_user != nil
      @verify = @@verify
    else
      @verify = params[:verify]
    end
    if @verify != nil && @verify == @@verify
    instanceid = params[:instanceid]
    @role = params[:role]
    url = request.request_uri
    uri = URI.parse(url)  
    query_params = uri.query
    @iptype = 'public'
    if params[:iptype] == 'private'
      @iptype = 'private'
    end
    if query_params != nil
      if instanceid != nil && !@role != nil
        @ec2machine = Ec2machine.find_by_instance_id(instanceid)
        if @ec2machine != nil
          @job = Job.find_by_ec2machine_id(@ec2machine.id)
          if @job.runcluster_id != nil
            jobs = Job.find(:all,:conditions => ["runcluster_id = ?", @job.runcluster_id])
            @ec2machines = Array.new
            count = 0
            jobs.each do |j|
              if j.role == @role
                @ec2machines[count] = Ec2machine.find(j.ec2machine_id)
                count = count + 1
              end
            end
          end
        end
      else
        if instanceid != nil
          @ec2machine = Ec2machine.find_by_instance_id(instanceid)
          if @ec2machine != nil
            @job = Job.find_by_ec2machine_id(@ec2machine.id)
            if @job.runcluster_id != nil
              jobs = Job.find(:all,:conditions => ["runcluster_id = ?", @job.runcluster_id])
              @ec2machines = Array.new
              count = 0
              jobs.each do |j|
                @ec2machines[count] = Ec2machine.find(j.ec2machine_id)
                count = count + 1
              end
            end
          end
        end
      end
    end
    else
      @verify = nil
    end
  end
  
  def set_param
    if current_user != nil
      @verify = @@verify
    else
      @verify = params[:verify]
    end
    if @verify != nil && @verify == @@verify
      instanceid = params[:instanceid]
      param_name = params[:param_name]
      param_value = params[:param_value]
      if instanceid.blank?
        @result = "Error: Instance ID in empty"
        return
      end      
      if param_name.blank?
        @result = "Error: Parameter name is empty"
        return
      end
     
      if instanceid != nil
        @job = Job.get_running_job_by_instanceid(instanceid)
        if @job.runcluster_id != nil
          runcluster = Runcluster.find(@job.runcluster_id)
          cluster_param = ClusterParam.new
          cluster_param.runcluster_id = runcluster.id
          cluster_param.param_name = param_name
          cluster_param.param_value = param_value
          cluster_param.save
          @result = "success"
        else
          @result = "Error: Job not found"
        end
      end
    else
      @verify = nil
    end
    respond_to do |format|
      format.html
      format.xml  { head :ok }
    end     
  end
  
  def get_param
    if current_user != nil
      @verify = @@verify
    else
      @verify = params[:verify]
    end
    if @verify != nil && @verify == @@verify
      instanceid = params[:instanceid]
      param_name = params[:param_name]
      if instanceid.blank?
        @result = "Error: Instance ID in empty"
        return
      end      
      if param_name.blank?
        @result = "Error: Parameter name is empty"
        return
      end
     
      if instanceid != nil
        @job = Job.get_running_job_by_instanceid(instanceid)
        if @job.runcluster_id != nil
          runcluster = Runcluster.find(@job.runcluster_id)
          cluster_param = ClusterParam.find(:last, :conditions=>"runcluster_id = #{runcluster.id} and param_name = '#{param_name}'")
          @result = cluster_param.param_value.to_s
        else
          @result = "Error: Job not found"
        end
      end
    else
      @verify = nil
    end
    respond_to do |format|
      format.html
      format.xml  { head :ok }
    end    
  end
end