class ConfigurationsController < ApplicationController
  layout "application",:except=>[:deploy_vdi_build, :undeploy_vdi_build]
  helper_method :deployjob
  def index
    teamnames_a = User.all_team.to_a
    if current_user.is_external
      @teamnames = Array.new
      filter = XFilter.new
      filter.equal 0, "deleted"
      search_name = params[:search_name]
      filter.like search_name.strip, "name" if !search_name.blank?
      filter.equal current_user.id, "user_id"
    else
      @teamnames = teamnames_a.collect{|teamname| [teamname.name,teamname.id]}
      filter = XFilter.new
      filter.equal 0, "deleted"
      if !params[:template_mapping_id].blank?
        filter.equal params[:template_mapping_id], "template_mapping_id"
      elsif !params[:template_id].blank?
        filter.equal params[:template_id], "template_id"
        filter.is_null("template_mapping_id")
      else
        search_name = params[:search_name]
        if search_name != nil && search_name.strip != ""
          filter.like search_name.strip, "name"
        end
        
        search_filter = params[:filter]
        if search_filter && search_filter[:search_team_id]!= ""
          team_id = search_filter[:search_team_id]
          template_ids = Template.find(:all, :conditions => ['team_id = ?', team_id])
          if template_ids.length != 0
            filter.in_set(template_ids.collect{|template_id| template_id.id }.join(","),"template_id")
          else
            filter.in_set("-1","template_id")
          end
        end
      end
    end
    
    @configurations = Configuration.find(:all, :conditions => filter.conditions, :order=> "id DESC")
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @configurations = @configurations.paginate  :page => params[:page],:per_page => per_page
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @configurations }
    end
  end
  
  def new
    @configuration = Configuration.new
    @tempalte_ids = params[:template_ids]
    if !@tempalte_ids.blank?
      @tempalte = Template.find(@tempalte_ids)
      @templatename = @tempalte.name
    end
    @template_mapping_id = params[:template_mapping_id]
    if !@template_mapping_id.blank?
      @template_mapping = TemplateMapping.find(@template_mapping_id)
      @tempalte = @template_mapping.template
    end
    
    @securities = Security.find(:all)
    @day = Time.now + 7*24*60*60
    @lease_time_list = ["1", "2", "3"]
    architecture = @tempalte.architecture
    @region = @tempalte.region
    if @region != "iland"
      if @tempalte.is_cluster_instance == 1
        @instancetype_names = Instancetype.find(:all,:conditions => "name in ('cc1.4xlarge', 'cg1.4xlarge')")
      else
        @instancetype_names = Instancetype.find(:all,:conditions => "architecture = '#{architecture}' and name not in ('cc1.4xlarge', 'cg1.4xlarge')and (dc !='iland' or dc is null)")
      end
    else
      @instancetype_names = Instancetype.find(:all,:conditions => "architecture = '#{architecture}' and dc ='iland'")
    end
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    only_ebs = config["only_ebs_instances"]
    if !@tempalte.is_ebs      
      @instancetype_names.each do | instance |
        if only_ebs.include?(instance.name)
          @instancetype_names.delete(instance)
        end          
      end
    end
    groups = Group.find(:all, :conditions => ['manager_id = ?', session[:user]])
    groups.each{|group|
      @groupname = group.name
    }
    
    if current_user.is_admin || current_user.is_team
      @configuration_deploymentway = config["conf_admin_job_deploymentway"].split(",")
    else
      @configuration_deploymentway = config["conf_other_user_job_deploymentway"].split(",")
    end
    @subnets = Subnet.find_all_by_region(@tempalte.region)
    if @subnets.size > 0
      if current_user.is_admin || current_user.is_team || current_user.is_tam
        @configuration_deploymentway << "vpc-default"
        #@configuration_deploymentway << "vpc-dedicated"
      end            
    end
    
    if !@tempalte.is_ebs
      @configuration_deploymentway.delete("DailyOff")
    end
    
    @poweroff_hourlist = ["0","1","2","3","4","5","6","7","8","9","10","11","12",
                "13","14","15","16","17","18","19","20","21","22","23"]
    @poweroff_minlist = ["0","10","20","30","40","50"]
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @configuration }
    end
  end
  
  def create
    @configuration = Configuration.new(params[:configuration])
    if !params[:template_mapping_id].blank?
      template_mapping = TemplateMapping.find(params[:template_mapping_id])
      @configuration.template_mapping_id = template_mapping.id
      @configuration.template_name  = "TemlateMapping -- " + template_mapping.template.name
      @configuration.template_id = template_mapping.template.id
    else
      template = Template.find(params[:template_id])
      @configuration.template_id = template.id
      @configuration.template_name = template.name
    end
    
    @configuration.user_id = current_user.id
    @configuration.created_at = Time.now
    @configuration.updated_at = Time.now
    @configuration.deleted = 0
    day = @configuration.lease_time
    if day > 3
      day = 3
    end
    instancetype = Instancetype.find(@configuration.instancetype_id).name
    if @configuration.is_vpc
      if instancetype == 't1.micro'
        flash[:notice] = 'VPC do not support instance type t1.micro' 
        redirect_to :action => "new", :template_ids=> @configuration.template_id
        return      
      end
    end
    @configuration.lease_time = day
    @configuration.save
    
    respond_to do |format|
      if @configuration.save
        flash[:notice] = 'Configuration was successfully created.'
        format.html { redirect_to :action => "show", :id => @configuration.id }
        format.xml  { render :xml => @configuration, :status => :created, :location => @configuration }
      else
        @tempalte_ids = params[:template_id]
        format.html { render :action => "new" }
        format.xml  { render :xml => @configuration.errors,:template_id =>@configuration.template_id, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    url = request.request_uri
    uri = URI.parse(url)  
    query_params = uri.query
    if query_params != nil
      if query_params.include?"congfigurationname"
        if uri.to_s.include?"webserviceDeployjob"
          webserviceDeployjob
        else
          webserviceUndeployjob
        end
      end
    else
      @configuration = Configuration.find(params[:id])
      if !@configuration.can_access(current_user)
        flash[:notice] = 'You have no permission to access this configuration'
        redirect_to :action => 'welcome',:controller=>'users'
        return        
      end
      @configuration_id = @configuration.id
      @template_mapping = @configuration.template_mapping
      if @template_mapping
        @tempalte = @template_mapping.template
      else
        @tempalte = Template.find(@configuration.template_id)
      end
      if @configuration.commands != nil
        @commands = @configuration.commands.split("\r\n")
      end
      if @configuration.init_commands != nil
        @init_commands = @configuration.init_commands.split("\r\n")
      end
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @configuration }
      end
    end
  end
  
  def edit
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    @configuration = Configuration.find(params[:id])
    if !@configuration.can_access(current_user)
      flash[:notice] = 'You have no permission to access this configuration'
      redirect_to :action => 'welcome',:controller=>'users'
      return        
    end
    @template_mapping = @configuration.template_mapping
    if @template_mapping
      @tempalte = @template_mapping.template
    else
      @tempalte = Template.find(@configuration.template_id)
    end
    @region = @tempalte.region
    groups = Group.find(:all, :conditions => ['manager_id = ?', session[:user]])
    groups.each{|group|
      @groupname = group.name
    }
    if @region != 'iland'
      @securitygroup = Securitygroup.find(@configuration.securitygroup_id).name
    end
    @instancetype_id = Instancetype.find(@configuration.instancetype_id).id.to_s
    @instancetype_architecture = Instancetype.find(@configuration.instancetype_id).architecture
    @poweroff_hourlist = ["0","1","2","3","4","5","6","7","8","9","10","11","12",
                "13","14","15","16","17","18","19","20","21","22","23"]
    @poweroff_minlist = ["0","10","20","30","40","50"]
    @lease_time_list = ["1", "2", "3"]
    if current_user.is_admin || current_user.is_team
      @configuration_deploymentway = config["conf_admin_job_deploymentway"].split(",")
    else
      @configuration_deploymentway = config["conf_other_user_job_deploymentway"].split(",")
    end
    if !@tempalte.is_ebs
      @configuration_deploymentway.delete("DailyOff")
    end
    @subnets = Subnet.find_all_by_region(@tempalte.region)
    if @subnets.size > 0
      if current_user.is_admin || current_user.is_team || current_user.is_tam
        @configuration_deploymentway << "vpc-default"
        #@configuration_deploymentway << "vpc-dedicated"
      end            
    end
  end
  
  def update
    @configuration = Configuration.find(params[:id])
    if @configuration.lease_time > 3
      @configuration.lease_time = 3
    end
    if !@configuration.can_access(current_user)
      flash[:notice] = 'You have no permission to access this configuration'
      redirect_to :action => 'welcome',:controller=>'users'
      return        
    end    
    instancetype = Instancetype.find(params[:configuration][:instancetype_id]).name
    if @configuration.is_vpc
      if instancetype == 't1.micro'
        flash[:notice] = 'VPC do not support instance type t1.micro' 
        redirect_to :action => "edit", :id=> @configuration.id
        return      
      end
    end
    @configuration.update_by = current_user.id
    respond_to do |format|
      if @configuration.update_attributes(params[:configuration])
        flash[:notice] = 'Configuration was successfully updated.'
        format.html { redirect_to :action => "show", :id => @configuration.id }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @configuration.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @configuration = Configuration.find(params[:id])
    if !@configuration.can_access(current_user)
      flash[:notice] = 'You have no permission to access this configuration'
      redirect_to :action => 'welcome',:controller=>'users'
      return        
    end    
    @configuration.deleted = 1
    @configuration.save
    
    respond_to do |format|
      format.html { redirect_to(configurations_url) }
      format.xml  { head :ok }
    end
  end
  
  def deployjob
    url = request.request_uri
    uri = URI.parse(url)  
    query_params = uri.query
    @configuration = Configuration.find(params[:id])
    if @configuration.deleted == 1
      flash[:notice] = 'The template has been removed'  
      redirect_to :action => "index"
      return
    end
    if !@configuration.can_access(current_user)
      flash[:notice] = 'You have no permission to access this configuration'
      redirect_to :action => 'welcome',:controller=>'users'
      return        
    end    
    
    @job = Job.new
    Job.deployjobfromconf(@job,@configuration, current_user)
    Configuration.add_userdata_as_commands(@job,@configuration)
    Configuration.generate_telnet_commands(@job,@configuration)
    
    respond_to do |format|
      format.html { redirect_to :action => "show", :id => @job.id, :controller=>"jobs" }# jobs/show.html.erb
      format.xml  { render :xml => @job }
    end
  end
  
  def webserviceDeployjob
    url = request.request_uri
    uri = URI.parse(url)  
    query_params = uri.query
    @configuration = ""
    congfigurationname = ""
    if query_params != nil
      if query_params.include?"congfigurationname"
        congfigurationname = query_params.split("=")[1]
        @configuration =  Configuration.find(:first, :conditions => ["name = :conf_name and deleted = 0", {:conf_name => congfigurationname}])
      end
    else
      @configuration = Configuration.find(params[:id])
    end
    if @configuration != nil
      @job = Job.new
      Job.deployjobfromconf(@job,@configuration,current_user)
      Configuration.add_userdata_as_commands(@job,@configuration)
      Configuration.generate_telnet_commands(@job,@configuration)
      @job_id = @job.id
      
      respond_to do |format|
        format.html { redirect_to :action => "showWebservicejob", :id => @job_id, :controller=>"jobs" }# jobs/showWebservicejob.html.erb
        format.xml  { render :xml => @job }
      end
    end 
  end
  
  def webserviceUndeployjob
    url = request.request_uri
    uri = URI.parse(url)  
    query_params = uri.query
    @configuration = ""
    congfigurationname = ""
    if query_params != nil
      if query_params.include?"congfigurationname"
        congfigurationname = query_params.split("=")[1]
        @configuration = Configuration.find(:first, :conditions => ["name = :conf_name and deleted = 0", {:conf_name => congfigurationname}])
      end
    else
      @configuration = Configuration.find(params[:id])
    end
    if @configuration != nil
      respond_to do |format|
        format.html { redirect_to :action => "destroyWebservicejob", :id => @configuration.id, :controller=>"jobs" }
        format.xml  { render :xml => @configuration }
      end
    end
  end
  
  def webservicePoweroffjob
    url = request.request_uri
    uri = URI.parse(url)  
    query_params = uri.query
    @configuration = ""
    congfigurationname = ""
    if query_params != nil
      if query_params.include?"congfigurationname"
        congfigurationname = query_params.split("=")[1]
        @configuration = Configuration.find(:first, :conditions => ["name = :conf_name and deleted = 0", {:conf_name => congfigurationname}])
      end
    else
      @configuration = Configuration.find(params[:id])
    end
    if @configuration != nil
      @jobs = Job.find(:all,:conditions => ['state in ("Run") and configuration_id = ?', @configuration.id])
      @jobs.each{|@job|
        @job.power_off
      }
      @result = "success"
    else
      @result = "Configuration not found"
    end 
  end
  
  
  def news
    @configuration = Configuration.new
    @tempalte_ids = params[:template_ids]
    if !@tempalte_ids.blank?
      @tempalte = Template.find(@tempalte_ids)
      @templatename = @tempalte.name
    end
    @template_mapping_id = params[:template_mapping_id]
    if !@template_mapping_id.blank?
      @template_mapping = TemplateMapping.find(@template_mapping_id)
      @tempalte = @template_mapping.template
    end
    
    @securities = Security.find(:all)
    @day = Time.now + 7*24*60*60
    @lease_time_list = ["1", "2", "3"]
    architecture = @tempalte.architecture
    @region = @tempalte.region
    if @region != "iland"
      if @tempalte.is_cluster_instance == 1
        @instancetype_names = Instancetype.find(:all,:conditions => "name in ('cc1.4xlarge', 'cg1.4xlarge')")
      else
        @instancetype_names = Instancetype.find(:all,:conditions => "architecture = '#{architecture}' and name not in ('cc1.4xlarge', 'cg1.4xlarge') and (dc != 'iland' or dc is null)")
      end
    else
      @instancetype_names = Instancetype.find(:all,:conditions => "architecture = '#{architecture}' and dc = 'iland'")
    end
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    only_ebs = config["only_ebs_instances"]
    if !@tempalte.is_ebs      
      @instancetype_names.each do | instance |
        if only_ebs.include?(instance.name)
          @instancetype_names.delete(instance)
        end          
      end
    end
    groups = Group.find(:all, :conditions => ['manager_id = ?', session[:user]])
    groups.each{|group|
      @groupname = group.name
    }
    
    if current_user.is_admin || current_user.is_team
      @configuration_deploymentway = config["conf_admin_job_deploymentway"].split(",")
    else
      @configuration_deploymentway = config["conf_other_user_job_deploymentway"].split(",")
    end
    if !@tempalte.is_ebs
      @configuration_deploymentway.delete("DailyOff")
    end
    
    @poweroff_hourlist = ["0","1","2","3","4","5","6","7","8","9","10","11","12",
                "13","14","15","16","17","18","19","20","21","22","23"]
    @poweroff_minlist = ["0","10","20","30","40","50"]
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @configuration }
    end
  end
  
  def create_a_batch
    @quantity = params[:quantity].to_i
    number = 1
    if !params[:template_mapping_id].blank?
      template_mapping = TemplateMapping.find(params[:template_mapping_id])
    else
      template = Template.find(params[:template_id])
    end
    @quantity.times{
      num_s = number
      if(number<10)
        num_s = 0.to_s + number.to_s
      else
        num_s = number.to_s
      end
      
      @configuration = Configuration.new(params[:configuration])
      if !params[:template_mapping_id].blank?
        @configuration.template_mapping_id = template_mapping.id
        @configuration.template_name  = "TemlateMapping -- " + template_mapping.template.name
        @configuration.template_id = template_mapping.template.id
      else
        @configuration.template_id = template.id
        @configuration.template_name = template.name
      end
      @configuration.name = @configuration.name
      @configuration.user_id = current_user.id
      @configuration.created_at = Time.now
      @configuration.updated_at = Time.now
      @configuration.deleted = 0
      day = @configuration.lease_time
      if day > 3
        day = 3
      end
      @configuration.lease_time = day
      @configuration.replace_index(num_s)
      @configuration.save
      number = number +1
    }
    redirect_to :action => "index"
  end
  
  def deploy_vdi_build
    congfigurationname = params[:congfigurationname]
    build_command = params[:build_command]
    lease_time = params[:lease_time].to_i
    role = params[:role]
    @error = ""
    @is_valid = true    
    if build_command.blank?
      @error = "Error: Build command should not empty"
      @is_valid = false
    end    
    if role.blank?
      #Single machine
      @configuration =  Configuration.find(:last, :conditions => ["name = :conf_name and deleted = 0", {:conf_name => congfigurationname}])
      if @configuration.nil?
        @error = "Error: Can't find the configuration with name: " + congfigurationname
        @is_valid = false 
      end
    
      @configuration.init_commands = params[:build_command]
      @configuration.lease_time = lease_time if lease_time > 0
      @configuration.lease_time = 3 if lease_time > 3
      
		
      if @is_valid
        if @configuration != nil
          @job = Job.new
          Job.deployjobfromconf(@job,@configuration,current_user)
          @job.init_commands = @configuration.init_commands
          Configuration.add_userdata_as_commands(@job,@configuration)
          @job_id = @job.id
          @job.usage = "VDIBuild"
          @job.save 
        end 
      end
    else
      #Cluster
      cluster =  Cluster.find(:last, :conditions => ["name = :clustername and state = 'available'", {:clustername => congfigurationname}])
        
      if cluster.nil?
        @error = "Error: Can't find the cluster configuration with name: " + congfigurationname
        @is_valid = false 
      end
      
      cluster_configuration = Clusterconfiguration.find(:first, :conditions =>"cluster_id = #{cluster.id} and role = '#{role}'")
      if cluster_configuration.nil?
        @error = "Error: Defined role is not found in the cluster"
        @is_valid = false 
      end
      if @is_valid
        run_cluster = Runcluster.new
        run_cluster.deploy_cluster_with_commands(cluster, current_user, build_command)
        @job = Job.find(:first, :conditions=>"runcluster_id = #{run_cluster.id} and role = '#{role}'")
        @job_id = @job.id
      end
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @job }
    end
  end
  def undeploy_vdi_build
    @job = Job.find(params[:id])
    if @job.can_write_job(current_user)
      if params[:state] == 'success'
        #TODO: When the gbuild is finilized, the job should be undeployed when the build success
        #@job.deletejob(@job) 
        runcluster = @job.runcluster
        if runcluster.nil?
          @job.power_off
        else
          runcluster.jobs.each do |j|
            begin
              j.power_off
            rescue Exception => e
              puts e.message
            end
          end
        end
      else
        runcluster = @job.runcluster
        if runcluster.nil?
          @job.power_off
        else
          runcluster.jobs.each do |j|
            begin
              j.power_off
            rescue Exception => e
              puts e.message
            end
          end
        end        
        #TODO: In development mode, keep the failed job running
        #for failed jobs, we need power it off and keep the job for 3 days more
#        @job.poweroff
#        @job.lease_time = Time.now + 3*24*60*60
#        @job.save
      end
      @result = "success"
    else
      @result = "Error, permissions error"
    end
  end
end
