require 'popen4'
class JobsController < ApplicationController
  layout "application", :except => [:showWebservicejob, :destroyWebservicejob, :initialcommand, :undeployJobByInstanceID]
  @@config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
  @@verify = @@config["verify"]
  # GET /jobs
  # GET /jobs.xml
  def index
    if current_user.is_admin
      @job_ids = Job.find_by_sql("select id from jobs order by id desc")
    else
      group_ids = Group.find_by_sql("select group_id from groups_users where user_id = #{current_user.id}")
      group_id_string = group_ids.collect { |g| g["group_id"] }.join(",")

      sql = "select jobs.id from jobs where user_id = #{current_user.id} "
      if group_ids.size > 0
        sql += " or ((rpermission = 1 or permission = 1) and   
                 group_id in (#{group_id_string}))"
      end
      sql += " order by id DESC"
      @job_ids = Job.find_by_sql(sql)
    end

    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    if @job_ids.size > 2000
      @job_ids = @job_ids.first(2000)
    end
    @job_ids = @job_ids.paginate :page => params[:page], :per_page => per_page

    job_ids_string = @job_ids.collect { |j| j["id"] }.join(",")
    if @job_ids.size == 0
      @jobs = Array.new
    else
      @jobs = Job.find_by_sql("select * from jobs where id in (#{job_ids_string})")
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @jobs }
    end
  end

  def byuser
    if current_user.is_admin
      userid = params[:userid]
      if params[:onlyactive] != nil && params[:onlyactive] == 'true'
        @jobs = Job.find_by_sql("select jobs.* from jobs where user_id = #{userid} 
                          and state in ('Run', 'Pending', 'Open', 'Deploying', 'PowerOFF', 'Capturing') order by id DESC")
      else
        @jobs = Job.find_by_sql("select jobs.* from jobs
              where user_id = #{userid} order by id DESC")
      end
    end
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @jobs = @jobs.paginate :page => params[:page], :per_page => per_page

  else
  end

  # GET /jobs/1
  # GET /jobs/1.xml
  def show
    @job = Job.find(params[:id])
    @job_id = @job.id
    @region = @job.region
    if !@job.can_read_job(current_user)
      flash[:notice] = 'You have no permission to visit this job'
      redirect_to :action => 'welcome', :controller => 'users'
      return
    end
    @tempalte = Template.find(@job.template_id)
    @cmds = Cmd.find(:all, :conditions => ['job_id = ?', @job.id])
    rdp_opened = @job.is_rdp_opened

    if @region == "iland"
      rdp_opened = true
    end
    if !rdp_opened && @job.state == "Run"
      flash[:notice] = "The RDP port is not open, please click 'Open RDP Port' link to open it"
    end
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    @add_group = config["add_group"]
    @change_group_port = config["change_group_port"]
    @create_instance = config["create_instance"]
    if @job.ec2machine_id == nil
      @ec2machine == nil
      @volumes = nil
    else
      @ec2machine = Ec2machine.find(@job.ec2machine_id)
      @volumes = Ec2machine.find_by_sql("select * from active_volumes where instance_id= '#{@ec2machine.instance_id}'")
    end

    if @job.ilandmachine_id == nil
      @ilandmachine == nil
    else
      @ilandmachine = Ilandmachine.find(@job.ilandmachine_id)
    end

    @telnetcommands = Runcommand.find(:all, :conditions => ['job_id = ?', @job.id])

    if @job.deploymentway == 'Spot' && @job.state == 'Run' && ((Time.now - @job.created_at) >= 2*60*60)
      #Add a warning if the spot is teminated
      spot = ActiveSpot.find(:first, :conditions => ["spot_id = '#{@job.request_id}'"])
      if spot.nil? || spot.status != 'active'
        flash[:notice] = 'This spot machine is undeployed by Amazon. So it may be already un-available now'
      end
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml {
        @machine = @ec2machine
        render :layout => false }
    end
  end

  # GET /jobs/new
  # GET /jobs/new.xml
  def new
    if !current_user.is_admin
      unsecure_jobs = Job.get_unsecure_jobs(current_user)
      if unsecure_jobs.size != 0
        redirect_to :action => "unsecure_jobs"
        return
      end
    end
    @job = Job.new
    #    @templates = Template.find(:all)
    @tempalte_ids = params[:template_ids]
    template = Template.find(params[:template_ids])
    @region = template.region

    if @region == 'ap-southeast-1' && !current_user.is_admin
      flash[:notice] = 'The templates out of region us-east-1 has been disabled. Please contact admin team if you need have issues.'
      redirect_to :action => 'welcome', :controller => 'users'
      return
    end

    if !template.can_access(current_user)
      flash[:notice] = 'You have no permission to access this template'
      redirect_to :action => 'welcome', :controller => 'users'
      return
    end
    architecture = template.architecture
    @templatename = template.name
    @is_virus_secure = template.is_virus_secure
    @day = Time.now + 7*24*60*60

    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    if @region != "iland"
      @securities = Security.find(:all)
      if template.is_cluster_instance == 1
        @instancetype_names = Instancetype.find(:all, :conditions => "name in ('cc1.4xlarge', 'cg1.4xlarge', 'cc2.8xlarge','hi1.4xlarge')", :order => "linux_price")
      else
        @instancetype_names = Instancetype.find(:all, :conditions => "architecture = '#{architecture}' and name not in ('cc1.4xlarge', 'cg1.4xlarge', 'cc2.8xlarge','hi1.4xlarge') and (dc != 'iland' or dc is null)", :order => "linux_price")
      end
      only_ebs = config["only_ebs_instances"]

      if !template.is_ebs
        temp_instance_list = Array.new
        @instancetype_names.each do |instance|
          if !only_ebs.include?(instance.name)
            temp_instance_list << instance
          end
        end
        @instancetype_names = temp_instance_list
      end

      # Take out older families of instance types for newer 64-bit templates
      if !current_user.is_admin
        @instancetype_names.delete_if do |instance|
          ((architecture == "i386") and (instance.name.start_with?('m3.', 'r3', 'g2', 'i2', 'c3'))) ||
          #((architecture == "x86_64") and (instance.name.start_with?('t1.', 'm1.'))) ||
              instance.name.start_with?('t2') || # Until we move to VPC, uncomment the previous line and delete this one (see VDI-2)
              instance.name.start_with?('r3', 'g2', 'i2') # Until we resolve VDI-12
        end

        temp_instance_list = Array.new
        @instancetype_names.each do |inst|
          if inst.name == "t1.micro" ||
              inst.name == "m1.small" ||
              inst.name == "t2.micro" ||
              inst.name == "t2.small" ||
              inst.name == "m1.small" ||
              inst.name == "m3.medium"
            temp_instance_list << inst
          elsif template.allow_large == 1 &&
              (current_user.is_team ||
                  current_user.is_role("vdi-write") ||
                  current_user.is_role("vdi-user") ||
                  current_user.is_tam)
            temp_instance_list << inst
          elsif template.allow_large == 1 && (inst.name == "m3.large" || inst.name == "c3.large" || inst.name == "c4.large")
            temp_instance_list << inst
          end
        end
        @instancetype_names = temp_instance_list
      end

      if current_user.is_admin || current_user.is_team || current_user.is_role("vdi-write") || current_user.is_sys_admin
        @job_deploymentway = config["admin_job_deploymentway"].split(",")
      else
        @job_deploymentway = config["other_user_job_deploymentway"].split(",")
      end

      if !template.is_ebs
        @job_deploymentway.delete("DailyOff")
      end
    else
      @instancetype_names = Instancetype.find(:all, :conditions => "architecture = '#{architecture}' and dc = 'iland'")
      @job_deploymentway = config["iland_job_deploymentway"].split(",")
    end

    groups = Group.find(:all, :conditions => ['manager_id = ?', session[:user]])
    groups.each { |group|
      @groupname = group.name
    }

    @subnets = Subnet.find_all_by_region(template.region)
    #if @subnets.size > 0
    #  @job_deploymentway << "vpc-default"
    #      if current_user.is_admin || current_user.is_team || current_user.is_tam
    #        @job_deploymentway << "vpc-dedicated"
    #      end
    #end
    @poweroff_hourlist = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12",
                          "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"]
    @poweroff_minlist = ["0", "10", "20", "30", "40", "50"]

    @job_usages = Array.new

    if current_user.is_admin || current_user.is_tam || current_user.is_team || current_user.is_vdi_user || current_user.is_vdi_write || current_user.is_external
      @job_usages << 'DevelopmentTask'
      @job_usages << 'Support'
    end

    if current_user.is_admin || current_user.is_partner || current_user.is_tam
      @job_usages << 'PartnerDevelopment'
    end

    if current_user.is_admin
      @job_usages << 'Production'
    end

    if current_user.is_admin || current_user.is_team || current_user.is_vdi_write
      @job_usages << 'Preview'
    end

    if current_user.is_sys_admin
      @job_usages << 'Production'
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @job }
    end
  end

  def import
    if params[:submit] != nil
      job_name = params[:job_name]
      instance_id = params[:instance_id]
      template_id = params[:template_id]

      if !job_name.blank? && !instance_id.blank?
        import_ec2machine = Ec2machine.new
        import_ec2machine.instance_id = instance_id.strip
        import_ec2machine.public_dns = ""
        import_ec2machine.status = "Deployed"
        import_ec2machine.save
        template = Template.find(template_id)
        @job = Job.new
        @job.name = job_name
        @job.user_id = 333
        @job.state = 'Run'
        @job.ec2machine_id = import_ec2machine.id
        @job.rpermission = 0
        @job.permission = 0
        @job.group_id = 1
        @job.lease_time = Time.now + 365*24*60*60
        @job.deploymentway = "normal"
        @job.instancetype_id = 1
        @job.securitygroup_id = 1
        @job.template_id = template_id
        @job.ami_name = template.ec2_ami
        @job.save

        redirect_to :action => "show", :id => @job.id
      end
    end
  end

  # GET /jobs/1/edit
  def edit
    @job = Job.find(params[:id])
    if !@job.can_write_job(current_user)
      flash[:notice] = 'You have no permission to visit this page '
      redirect_to :action => 'welcome', :controller => 'users'
    end
    @tempalte = Template.find(@job.template_id)
    groups = Group.find(:all, :conditions => ['manager_id = ?', session[:user]])
    groups.each { |group|
      @groupname = group.name
    }
    @securitygroup = Securitygroup.find(@job.securitygroup_id).name
    @instancetype = Instancetype.find(@job.instancetype_id).name
    @deploymentway = ["DailyOff", "normal"]
    @poweroff_hourlist = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12",
                          "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"]
    @poweroff_minlist = ["0", "10", "20", "30", "40", "50"]
    if current_user.is_admin
      @sys_admins = User.all_sys_admin
    end
    if current_user.is_sys_admin
      @sys_admins = Array.new
      @sys_admins << current_user
    end
  end

  def update_password
    @job = Job.find(params[:id])
    if @job.machinepassword.blank?
      @job.machinepassword = @job.template.password
    end
    if !@job.can_write_job(current_user)
      flash[:notice] = 'You have no permission to visit this page '
      redirect_to :action => 'welcome', :controller => 'users'
    end
  end

  # POST /jobs
  # POST /jobs.xml
  def create
    @job = Job.new(params[:job])
    @job.template_id = params[:template_id]
    @job.user_id = current_user.id

    is_job_valid = true
    if !@job.name || @job.name.strip== ""
      flash[:notice] = 'Job name should not be empty'
      is_job_valid = false
    end
    if @job.usage == "PartnerDevelopment"
      project_id = params[:job][:project_id]
      if !project_id || project_id.strip.length == 0 || (project_id.gsub(/[0-9]*/, "")).strip.length != 0
        flash[:notice] = 'Webeeh Project ID should be correctly input for Webeeh related jobs'
        is_job_valid = false
      end
    end
    template = Template.find(@job.template_id)
    @region = template.region
    if template.deleted == 1
      flash[:notice] = 'The template has been removed'
      is_job_valid = false
    end

    if !template.can_access(current_user)
      flash[:notice] = 'You have no permission to access this template'
      redirect_to :action => 'welcome', :controller => 'users'
      return
    end

    instancetype = Instancetype.find(@job.instancetype_id).name
    if @job.is_vpc
      if instancetype == 't1.micro'
        flash[:notice] = 'VPC do not support instance type t1.micro'
        is_job_valid = false
      end
    end
    if !is_job_valid
      redirect_to :action => "new", :template_ids => @job.template_id
      return
    end

    #if @job.usage == 'Preview' || @job.usage == 'Production'
    #  @job.deploymentway = 'normal'
    #end

    if !@job.lease_time
      if @job.usage == "Acceptance" || @job.usage == "Consumption"
        @job.lease_time = Time.now + 2*24*60*60
      else
        @job.lease_time = Time.now + 7*24*60*60
      end
    end

    if @job.group_id.blank?
      @job.group_id = 1
    end

    platform = template.platform

    #change the deployment type to normal for types only can deploy in normal way.
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")

    if @job.deploymentway == "DailyOff" && @region != 'iland'
      # S3 instance do not support Daily off
      if !template.is_ebs
        @job.deploymentway = "Spot"
      end
    end

    if @job.deploymentway == "Spot"
      # Dev pay instances do not support spot deployment
      # no spot instance should not go with spot

      no_spot = false
      os = 'Windows'
      if template.platform != 'Windows'
        os = 'Linux'
      end
      active_spots = ActiveSpot.find(:all, :conditions => "status in ('active', 'open') and
                            instance_type = '#{instancetype}' and region='#{template.region}'
                            and os='#{os}'")
      spot_quota = SpotQuota.find(:first, :conditions => "instance_type = '#{instancetype}' and region='#{template.region}'
                            and os='#{os}'")
      spot_quota_count = @@config["default_spot_quota"].to_i
      if !spot_quota.nil?
        spot_quota_count = spot_quota.quota
      end
      if active_spots.size >= spot_quota_count
        no_spot = true
      end

      #Currently, US region do not support spot...
      #      if instancetype == 'm1.small' && template.region == 'us-east-1' && platform == "Windows"
      #        no_spot = true
      #      end
      if template.dev_pay == 1 || no_spot == true
        @job.deploymentway = "DailyOff"
      else
        max_price = ""
        if platform == "Windows"
          max_price = Instancetype.find_by_name(instancetype).windows_maxprice
        else
          max_price = Instancetype.find_by_name(instancetype).linux_maxprice
        end
      end
    end
    @job.max_price = max_price
    ami_name = template.ec2_ami
    @job.ami_name = ami_name
    if @job.securitygroup_id == nil
      @job.securitygroup_id = 1
      @job.securitytype_name=""
    end
    #    @job.securitytype_id = 1
    @job.state = "Pending"
    @job.telnet_service = "stop"
    @job.region = @region
    if template.telnet_enabled == 0
      @job.telnet_service = "disabled"
    end
    @job.save
    if @region != "iland"
      @job.securitytype_name = current_user.name.gsub(/\W/, '') + "_" + Job.find(:last).id.to_s + "_1"
      #    @job.securitytype_id = Job.find(:last).id

      securitygroup = Securitygroup.find(@job.securitygroup_id)
      securities = securitygroup.securities

      @job.addcommand(@job, securities, instancetype, nil)
    else
      newappcmd = @job.addcommandiland(@job, instancetype, nil)
      state = Cmd.run_newvapp_command_for_iland(newappcmd)
      #new ilandmachine
      if state != "Fail"
        @ilandmachine = Ilandmachine.new
        @ilandmachine.vapp_id = state
        @ilandmachine.platform = template.platform
        @ilandmachine.lifecycle = @job.deploymentway
        @ilandmachine.status = "Deploying"
        getilandmachine = @ilandmachine.save
        if getilandmachine
          @job.ilandmachine_id = @ilandmachine.id
          @job.is_busy = 1
          @job.state = "Pending"
        end
      else
        @job.state = "Build Fail"
        @job.is_busy = 0
        @job.save
      end
    end

    respond_to do |format|
      if @job.save
        flash[:notice] = 'Job was successfully created.'
        format.html { redirect_to :action => "show", :id => @job.id }
        format.xml { render :xml => @job, :status => :created, :location => @job }
      else
        @tempalte_ids = params[:template_id]
        format.html { render :action => "new" }
        format.xml { render :xml => @job.errors, :template_id => @job.template_id, :status => :unprocessable_entity }
      end
    end
  end


  # PUT /jobs/1
  # PUT /jobs/1.xml
  def update
    @job = Job.find(params[:id])
    if !@job.can_write_job(current_user)
      flash[:notice] = 'You have no permission to visit this page '
      redirect_to :action => 'welcome', :controller => 'users'
    end
    is_job_valid = true
    if @job.usage == "PartnerDevelopment" || @job.usage == "Rebuttal" || @job.usage == "Acceptance" || @job.usage == "Consumption"
      project_id = params[:job][:project_id]
      if (!project_id || project_id.strip.length == 0 || (project_id.gsub(/[0-9]*/, "")).strip.length != 0) && @job.project_id.blank?
        flash[:notice] = 'Webeeh Project ID should be correctly input for Webeeh related jobs'
        is_job_valid = false
      end
    end
    if !is_job_valid
      redirect_to :action => "edit", :id => @job.id
      return
    end

    respond_to do |format|
      if @job.update_attributes(params[:job])
        flash[:notice] = 'Job was successfully updated.'
        format.html { redirect_to :action => "show", :id => @job.id }
        format.xml { head :ok }
      else
        @templates = Template.find(:all)
        format.html { render :action => "edit" }
        format.xml { render :xml => @job.errors, :status => :unprocessable_entity, :object => @templates }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.xml
  def destroy
    @job = Job.find(params[:id])
    if !@job.can_write_job(current_user)
      flash[:notice] = 'You have no permission to visit this page '
      redirect_to :action => 'welcome', :controller => 'users'
    end
    @job.deletejob(@job)

    respond_to do |format|
      format.html { redirect_to :action => "show", :id => @job.id }
      format.xml { head :ok }
    end
  end

  # Reboot the machine
  def reboot
    @job = Job.find(params[:id])
    if !@job.can_write_job(current_user)
      flash[:notice] = 'You have no permission to visit this page '
      redirect_to :action => 'welcome', :controller => 'users'
    end
    @job.reboot

    redirect_to :action => "show", :id => @job.id
  end

  # Stop the machine
  def stop
    @job = Job.find(params[:id])
    if !@job.can_write_job(current_user)
      flash[:notice] = 'You have no permission to visit this page '
      redirect_to :action => 'welcome', :controller => 'users'
    end
    @job.power_off
    redirect_to :action => "show", :id => @job.id
  end

  # Start the machine
  def start
    @job = Job.find(params[:id])
    if !@job.can_write_job(current_user)
      flash[:notice] = 'You have no permission to visit this page '
      redirect_to :action => 'welcome', :controller => 'users'
    end
    if @job.locked == 1 && !current_user.is_admin
      flash[:notice] = 'Failed to Power On the VM as this job is locked. It is possibly that the template is virus infected. Please contact VDI Kinson (Skype: xqs1010) or Alex(skype: axelaris) to get the important data from the vm'
      redirect_to :action => 'show', :id => @job.id
      return
    end
    @job.power_on
    redirect_to :action => "show", :id => @job.id
  end

  def lock
    @job = Job.find(params[:id])
    if current_user.is_admin
      @job.locked = 1
      @job.save
    end
    redirect_to :action => "show", :id => @job.id
  end

  def unlock
    @job = Job.find(params[:id])
    if current_user.is_admin
      @job.locked = 0
      @job.save
    end
    redirect_to :action => "show", :id => @job.id
  end

  def refreship
    @job = Job.find(params[:id])
    if !@job.can_write_job(current_user)
      flash[:notice] = 'You have no permission to visit this page '
      redirect_to :action => 'welcome', :controller => 'users'
    end
    ec2machine = @job.ec2machine
    ec2machine.public_dns = ""
    ec2machine.private_dns = ""
    ec2machine.public_ip = ""
    ec2machine.save
    redirect_to :action => "show", :id => @job.id
  end

  def newcommands
    @new_commands = Newcommand.new
    @job = Job.find(params[:id])
    @job_id = @job.id
    @commands = ""
    respond_to do |format|
      format.html # newcommands.html.erb
      format.xml { render :xml => @new_commands }
    end
  end

  def commandsreturn
    @job_id = params[:job_id]
    @run_commands = Runcommand.find(params[:id])
    respond_to do |format|
      format.html
      format.xml { render :xml => @run_commands }
    end
  end

  def showWebservicejob
    @job = Job.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @job }
    end
  end

  def destroyWebservicejob
    @jobs = Job.find(:all, :conditions => ['state in ("Run", "PowerOFF") and configuration_id = ?', params[:id]])
    @jobs.each { |@job|
      @job.deletejob(@job)
    }
    respond_to do |format|
      format.html
      format.xml { head :ok }
    end
  end

  def undeployJobByInstanceID
    if current_user != nil
      @verify = @@verify
    else
      @verify = params[:verify]
    end
    @result = false
    @error = ""
    if @verify != nil && @verify == @@verify
      instanceid = params[:instanceid]
      if !instanceid.nil?
        @ec2machines = Ec2machine.find(:all, :conditions => "instance_id = '#{instanceid}'")
        if @ec2machines.size > 0
          for ec2machine in @ec2machines
            job = Job.find(:first, :conditions => "ec2machine_id = '#{ec2machine.id}'")
            puts job.id.to_s
            if !job.nil?
              if !job.configuration.nil?
                if Job::STATUS[:active].include?(job.state)
                  job.deletejob(job)
                  @result = true
                else
                  @error = "Error: The job has been undeployed"
                end
              else
                @error = "Error: The job is not deployed from configuration"
              end
            else
              @error = "Error: No job was found with this instance ID"
            end
          end
        else
          @error = "Error: The instance was not found"
        end
      else
        @error = "Error: The instance id was not specified"
      end
    else
      @verify = nil
    end
    respond_to do |format|
      format.html
      format.xml { head :ok }
    end
  end

  def actives
    if current_user.is_admin
      @jobs = Job.find(:all, :conditions => ["state in ('Run', 'Pending', 'Open', 'Deploying', 'PowerOFF', 'Capturing')"], :order => "id DESC")
    else
      sql = "select jobs.* from jobs
            where (state in ('Run', 'Pending', 'Open', 'Deploying', 'PowerOFF', 'Capturing')) and(
               user_id = #{current_user.id}  or
               ((rpermission = 1 or permission = 1) and   
            group_id in (select group_id from groups_users where user_id = #{current_user.id}))"
      sql += " or `usage` in ('Configuration', 'VDIBuild')" if current_user.is_testbreak_team
      sql += ") order by id DESC"
      @jobs = Job.find_by_sql(sql)
    end

    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @jobs = @jobs.paginate :page => params[:page], :per_page => per_page

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @jobs }
    end
  end

  def history
    if current_user.is_admin
      @job_ids = Job.find_by_sql("select id from jobs where state in ('Build Fail', 'Undeploy', 'Expired', 'Spot Fail') order by id desc")
    else
      group_ids = Group.find_by_sql("select group_id from groups_users where user_id = #{current_user.id}")
      group_id_string = group_ids.collect { |g| g["group_id"] }.join(",")

      sql = "select jobs.id from jobs where (state in ('Build Fail', 'Undeploy', 'Expired', 'Spot Fail')) and (user_id = #{current_user.id} "
      if group_ids.size > 0
        sql += " or ((rpermission = 1 or permission = 1) and
                 group_id in (#{group_id_string}))"
      end
      sql += ") order by id DESC"
      @job_ids = Job.find_by_sql(sql)
    end

    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    if @job_ids.size > 2000
      @job_ids = @job_ids.first(2000)
    end
    @job_ids = @job_ids.paginate :page => params[:page], :per_page => per_page

    job_ids_string = @job_ids.collect { |j| j["id"] }.join(",")
    if @job_ids.size == 0
      @jobs = Array.new
    else
      @jobs = Job.find_by_sql("select * from jobs where id in (#{job_ids_string})")
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @jobs }
    end
  end

  def supported
    if current_user.is_admin
      @jobs = Job.find(:all, :conditions => "support_id is not null", :order => "id DESC")
    elsif current_user.is_sys_admin
      @jobs = Job.find(:all, :conditions => "support_id = #{current_user.id}", :order => "id DESC")
    else

    end
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @jobs = @jobs.paginate :page => params[:page], :per_page => per_page

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @jobs }
    end
  end

  def myjobs
    active = params[:active]
    unless active
      @jobs = Job.find_by_sql("select jobs.* from jobs
         where state in ('Run', 'Pending', 'Open', 'Deploying', 'PowerOFF', 'Capturing')  and  user_id = #{current_user.id} order by id DESC")
    else
      @jobs = Job.find_by_sql("select jobs.* from jobs
         where user_id = #{current_user.id} order by id DESC")
    end
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @jobs = @jobs.paginate :page => params[:page], :per_page => per_page

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @jobs }
    end
  end

  def myteamjobs
    groups = Group.managed_groups(current_user)
    if groups.size == 0
      flash[:notice] = "You are not group manager. You have no permission to view your group jobs"
      @jobs = Array.new
    else
      users = Array.new
      for group in groups
        users = users + group.users
      end
      user_ids = users.collect { |u| u.id }.join(', ')
      active_state = "('" + Job::STATUS[:active].join("','")+"')"
      @jobs = Job.find_by_sql("select j.* from jobs j
           left join users u
           on u.id = j.user_id
           where u.id in (#{user_ids}) and j.state in #{active_state} order by id DESC")
    end
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @jobs = @jobs.paginate :page => params[:page], :per_page => per_page

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @jobs }
    end
  end

  def templatejobs
    @template_id = params[:templateid]
    template = Template.find(@template_id)
    @template_name = nil
    if template
      @template_name = template.name
    end
    if current_user.is_admin
      @jobs = Job.find(:all, :conditions => ["template_id = #{@template_id}"], :order => "id DESC")
    else
      @jobs = Job.find_by_sql("select jobs.* from jobs
            where (template_id = #{@template_id})  and(
               user_id = #{current_user.id}  or
               ((rpermission = 1 or permission = 1) and   
            group_id in (select group_id from groups_users where user_id = #{current_user.id}))) 
            order by id DESC")
    end

    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @jobs = @jobs.paginate :page => params[:page], :per_page => per_page

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @jobs }
    end
  end

  def initialcommand
    if current_user != nil
      @verify = @@verify
    else
      @verify = params[:verify]
    end
    if @verify != nil && @verify == @@verify
      url = request.request_uri
      uri = URI.parse(url)
      query_params = uri.query
      if query_params != nil
        instanceid = params[:instanceid]
        if instanceid != nil
          ec2machine = Ec2machine.find(:last, :conditions => ["instance_id='#{instanceid}'"])
          if ec2machine != nil
            @job = Job.find_by_ec2machine_id(ec2machine.id)
            if @job.configuration_id != nil && @job.configuration_id != ""
              configuration = Configuration.find(@job.configuration_id)
              @initcommands = configuration.init_commands
            end
          end
        end
        respond_to do |format|
          format.html
          format.xml { head :ok }
        end
      end
    else
      @verify = nil
    end
  end

  def generate_rdp
    data = "
            screen mode id:i:2\n
            full address:s:#{params[:public_dns]}\n
            username:s:#{params[:user]}\n
    \n
            compression:i:1\n
            keyboardhook:i:2\n
            audiomode:i:2\n
            redirectdrives:i:0\n
            redirectprinters:i:0\n
            redirectcomports:i:0\n
            redirectsmartcards:i:1\n
            displayconnectionbar:i:1\n
            autoreconnection enabled:i:1\n
            authentication level:i:0\n
            alternate shell:s:\n
            shell working directory:s:\n
            disable wallpaper:i:1\n
            disable full window drag:i:0\n
            disable menu anims:i:0\n
            disable themes:i:0\n
            disable cursor setting:i:0\n
            bitmapcachepersistenable:i:1\n"
    send_data data, :filename => params[:public_dns] + ".rdp", :type => "application/rdp"
  end

  def unsecure_jobs
    @jobs = Job.get_unsecure_jobs(current_user)
  end

  def open_port
    @job = Job.find(params[:id])
    port = params[:portname]
    source = "0.0.0.0/0"
    if params[:source] == 'me'
      source = get_user_ip + "/32"
    end
    if !@job.can_write_job(current_user)
      flash[:notice] = 'You have no permission to visit this page '
      redirect_to :action => 'welcome', :controller => 'users'
    end
    cmd = Cmd.open_port(@job, @job.ec2machine, port, source)
    if cmd
      state = Cmd.run_port_command(cmd)
      if state == "Success"
        flash[:notice] = 'Port opened successfully'
      else
        flash[:notice] = 'Failed to open port, please contact admin'
      end
    end
    redirect_to :action => "show", :id => @job.id
  end

  def close_port
    @job = Job.find(params[:id])
    port = params[:portname]
    if !@job.can_write_job(current_user)
      flash[:notice] = 'You have no permission to visit this page '
      redirect_to :action => 'welcome', :controller => 'users'
    end
    cmd = Cmd.close_port(@job, @job.ec2machine, port)
    if cmd
      state = Cmd.run_port_command(cmd)
      if state == "Success"
        flash[:notice] = 'port closed successfully'
      else
        flash[:notice] = 'Failed to close port, please contact admin'
      end
    end
    redirect_to :action => "show", :id => @job.id
  end

  def get_job_info
    @job = nil
    @submit = params[:submit]
    if @submit
      ip = params[:ip]
      if Ec2machine.is_valid_ip(ip)
        dns = ip.gsub(/\./, "-")
        machine = Ec2machine.find(:last, :conditions => "(public_ip = '#{ip}' || public_dns like '%#{dns}%') and status != 'Undeployed'")
        if machine
          @job = Job.find(:last, :conditions => "ec2machine_id = #{machine.id}")
        end
      end
      if Ilandmachine.is_valid_ip(ip)
        dns = ip.gsub(/\./, "-")
        ilandmachine = Ilandmachine.find(:last, :conditions => "(public_dns = '#{ip}' || public_dns like '%#{dns}%') and status != 'Undeployed'")

        if ilandmachine
          @job = Job.find(:last, :conditions => "ilandmachine_id = #{ilandmachine.id}")
        end
      end
    end
  end

  def getActiveVDIJobs
    @jobs = Job.find(:all, :include => [:instancetype, :user, :template], :conditions => "state in (#{Job::STATUS[:active].collect { |s| '\'' + s + '\'' }.join(',')})")
    respond_to do |format|
      format.json { render :json => @jobs.collect { |job| active_vdi_jobs_to_json job } }
    end
  end

  def extend_lease
    @job = Job.find(params[:id])
    if request.post?
      days = params[:days]
      reason = params[:reason]
      if reason.blank? || reason.strip.size < 30
        return flash[:notice] = "Please input the reason correctly!"
      end
      days = days.to_i
      if days < 1 || days > 7
        days = 1
      end
      if @job.lease_time.blank? || (!@job.can_extend_lease? && !current_user.is_admin)
        return flash[:notice] = "Can't extend job:#{@job.id}!"
      end
      ell = ExtendLeaseLog.new
      ell.days = days
      ell.reason = reason
      ell.created_on = Time.now
      ell.user = current_user
      ell.job = @job
      ell.old_lease_time = @job.lease_time
      ell.new_lease_time = @job.lease_time + (days * 24 * 3600)
      if ell.save
        @job.lease_time = ell.new_lease_time
        @job.save
        flash[:notice] = "Extend Success!"
        redirect_to :action => "show", :id => @job
      end
    end
  end

end
