class TemplatesController < ApplicationController
  include TemplatesHelper
  # GET /templates
  # GET /templates.xml
  def index
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    @regions = config["regions"].split(",")    
    
    filter = XFilter.new
    
    search_name = params[:search_name]
    if search_name != nil && search_name.strip != ""
      filter.like search_name.strip, "name"
    end
    search_filter = params[:filter]
    
    if search_filter && search_filter[:isdeleted]
      isdelete = search_filter[:isdeleted]
      if isdelete == "deleted"
        filter.equal 1, "deleted"
      else
        filter.equal 0, "deleted"
      end
    else
      filter.equal 0, "deleted"
    end
    
    if search_filter && search_filter[:team_id]     
      team_id = search_filter[:team_id]
      if team_id !=nil && team_id.strip != "" 
        filter.equal team_id, "team_id"
      end
    end
    
    if search_filter && search_filter[:region]     
      filter_region = search_filter[:region]
      if filter_region !=nil && filter_region.strip != "" 
        filter.equal filter_region, "region"
      end
    end
    
    if search_filter && !search_filter[:arch].blank?  
      filter.equal search_filter[:arch], "architecture"
    end
    
    if search_filter && !search_filter[:os].blank?     
      filter_os = search_filter[:os]
      if filter_os == "windows"         
        filter.equal "Windows", "platform"
      else
        filter.not_equal "Windows", "platform"
      end
    end    
    
    if params[:region] != nil && params[:region].strip != ''
      filter.equal params[:region], 'region' 
    end
    
    @templates = Template.find(:all, :conditions => filter.conditions, :order=> "id DESC")
    
    # external user can only access public templates or the template shared to him
    if current_user.is_external
      temp_list = Array.new
      group_ids = Array.new
      groups = current_user.groups
      for group in groups
        group_ids<< group.id
      end
      for template in @templates 
        if template.ispublic == 1 || group_ids.include?(template.group_id)
          temp_list << template
        end
      end
      @templates = temp_list
    end    
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @templates = @templates.paginate  :page => params[:page],:per_page => per_page
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @templates }
    end
  end
  
  def base_templates
    filter = XFilter.new
    filter.equal 0,"deleted"
    filter.equal 1,"base_template"
    @templates = Template.find(:all, :conditions => filter.conditions, :order=> "id DESC")
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @templates = @templates.paginate  :page => params[:page],:per_page => per_page
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @templates }
    end
  end
  
  # GET /templates/1
  # GET /templates/1.xml
  def show
    @show_template = Template.find(params[:id])
    if current_user.is_external
      if !@show_template.can_access(current_user)
        flash[:notice] = "You have no access to template: " + @show_template.id.to_s
        redirect_to :action => "index", :controller => "templates"
        return
      end
    end
    @shared_group = "N/A"
    if @show_template.group_id != 0 && current_user.is_admin
      group = Group.find(@show_template.group_id)
      @shared_group = group.name
    end
    
    @show_software = Software.all(:joins=>["LEFT JOIN templates_softwares tp_sft ON softwares.id= tp_sft.software_id"],:conditions=>["tp_sft.template_id = #{@show_template.id}"])
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @show_software = @show_software.paginate  :page => params[:page],:per_page => per_page
    
    @templates_exported = TemplatesExported.find(:first, :conditions=>"id = #{@show_template.id}")
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @show_template }
    end
  end
  
  def add_software_to_template
    template = Template.find(params[:template])
    software = Software.find(params[:template_software][:software])
    unless template.softwares.include?(software)
      template.softwares << software
      template.save
      flash[:notice] = 'Software was successfully added.'
    else
      flash[:notice] = 'Software was already added.'
    end
    redirect_to :action=>'show',:controller=>'templates',:id=>params[:template]
  end
  
  def remove_software_from_template
    template = Template.find(params[:id])
    software = Software.find(params[:software])
    if template.softwares.include?(software)
      template.softwares.delete(software)
      template.save
      flash[:notice] = 'Software was successfully removed.'
    end
    redirect_to :action=>'show',:controller=>'templates',:id=>params[:id]
  end
  
  def template_trace
    @this_template = Template.find(params[:id])
    @scope = params[:scope]
    if current_user.is_external
      #External user can only access the team scope
      @scope = "team"      
    end
  end
  
  # GET /templates/new
  # GET /templates/new.xml
  def new
    @new_template = Template.new
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    @regions = config["regions"].split(",")
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @new_template }
    end
  end
  
  # GET /templates/newiland
  # GET /templates/newiland.xml
  def newiland
    @new_template = Template.new
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    @regions = config["iland_region"].split(",")
    respond_to do |format|
      format.html # newiland.html.erb
      format.xml  { render :xml => @new_template }
    end
  end
  
  # GET /templates/1/edit
  def edit
    @edit_template = Template.find(params[:id])
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    @regions = config["regions"].split(",")
    if !can_manage_template(current_user, @edit_template)
      flash[:notice] = 'You have no permission'
      redirect_to :action => "index"
    end
  end
  
  # POST /templates
  # POST /templates.xml
  def create
    @new_template = Template.new(params[:template])
    @new_template.creator_id = @user.id
    @region = @new_template.region
    if @region != "iland"
      ami_name = @new_template.ec2_ami
      config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
      pk = config["ec2_bin_path"] + config["pk"]
      cert = config["ec2_bin_path"] + config["cert"]
      command = config["ec2_bin_path"] + config["get_ami_command"]
      cmd = command + ' ' +  ami_name + ' -K ' + pk +' -C ' + cert + ' --region ' + @new_template.region
      
      if ami_name[0,4] != "ami-" 
        respond_to do |format|
          flash[:notice] = 'Invalid Ec2 ami: ' + ami_name + ' (expecting "ami-...").'
          format.html { render :action => "new" }
          format.xml  { render :xml => @new_template.errors, :status => :unprocessable_entity }
        end
      else
        result = Template.createTemplate(cmd, @new_template)
        if !result
          respond_to do |format|
            flash[:notice] = 'The AMI ID ' + ami_name + ' does not exist. Or create template failed'
            format.html { render :action => "new" }
            format.xml  { render :xml => @new_template.errors, :status => :unprocessable_entity }
          end
        else        
          respond_to do |format|
            flash[:notice] = 'Template was successfully created.'
            format.html { redirect_to :action=>"show", :id=>@new_template.id }
            format.xml  { render :xml => @new_template, :status => :created, :location => @new_template }
          end
        end
      end
    else
      @new_template.state = "available"
      @new_template.save
      respond_to do |format|
        flash[:notice] = 'Template was successfully created.'
        format.html { redirect_to :action=>"show", :id=>@new_template.id }
        format.xml  { render :xml => @new_template, :status => :created, :location => @new_template }
      end
    end
  end
  
  
  
  # PUT /templates/1
  # PUT /templates/1.xml
  def update
    #    render :text =>'<pre>aaaaaaaaaaaa'+params.to_yaml and return
    @edit_template = Template.find(params[:id])
    if params[:template][:group_id] && params[:template][:group_id] == ''
      params[:template][:group_id] = 0
    end 
    if !can_manage_template(current_user, @edit_template)
      flash[:notice] = 'You have no permission'
      redirect_to :action => "index"
      return
    end
    respond_to do |format|
      if @edit_template.update_attributes(params[:template])
        flash[:notice] = 'Template was successfully updated.'
        format.html { redirect_to :action=>"show", :id=>@edit_template.id }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @edit_template.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /templates/1
  # DELETE /templates/1.xml
  def destroy
    @template = Template.find(params[:id])
    if (@template.state == 'available' ||  @template.state == 'failed' || @template.ec2_ami.blank?) && can_manage_template(current_user, @template)
      @template.deleted = 1
      @template.deleted_by = @user.id
      @template.save     
    else
      if !can_manage_template(current_user, @template)
        flash[:notice] = 'You have no permission'
      else
        flash[:notice] = 'Template is not in available state, please try again later.'
      end
    end    
    respond_to do |format|
      format.html { redirect_to(templates_url) }
      format.xml  { head :ok }
    end
  end
  
  def capturetemplate
    job = Job.find(params[:jobid])
    @job = job
    @job_name = job.name
    @job_id = job.id
    @job_state = job.state
    template = Template.new
    template.name = params[:name]
    template.description = params[:description]
    template.user = params[:user]
    template.password = params[:password]
    template.region = job.template.region
    template.creator_id = @user.id
    template.architecture = @job.instancetype.architecture
    @message = params[:message].blank? ? "" : params[:message] 
    
    if template.region == 'iland'
      flash[:notice] = 'Please contact admin to create iland template'
      redirect_to :action => 'welcome',:controller=>'users'
      return     
    end
     
    unless template.name.blank? 
      _template = Template.find_by_name(template.name)
      @message += "Templcate name #{template.name} Exist!" if _template
      res = /^[\w\d\s\-\_\.]*$/.match(template.name)
      @message += "Template name can only contain (characters, numbers, spaces, '-', '_', '.')" if res.nil?
      if !@message.blank?
        return redirect_to :action => "capturetemplate",:jobid=>@job_id,:message=>@message
      end  
    end
    
    if template.region == 'ap-southeast-1' && !current_user.is_admin
      flash[:notice] = 'The templates out of region us-east-1 has been disabled. Please contact admin team if you need have issues.'
      redirect_to :action => 'welcome',:controller=>'users'
      return  
    end    
    
    if params[:team]
      template.team_id = params[:team][:team_id]
    end
    if !template.team_id
      template.team_id = job.template.team_id
    end
    if current_user.is_external
      template.group_id = current_user.groups.first.id
    end
    if template != nil
      template_name = template.name
      template_desc = template.description
      template_region = job.template.region
      if template_name == nil || template_desc == nil || template_name.strip == "" || template_desc.strip == ""
        flash[:notice] = 'Please specify the template name and desciption'
      else    
        if template_region != "iland"
          config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
          pk = config["ec2_bin_path"] + config["pk"]
          cert = config["ec2_bin_path"] + config["cert"]
          command = config["ec2_bin_path"] + config["ec2-create-image"]
          command = command + ' -K ' + pk +' -C ' + cert
          command = command + ' --region ' + template.region
          command = command + ' -n "'  + template_name + '" -d "' + template_desc + '" '
          command = command + job.ec2machine.instance_id
          cmd = Cmd.new()
          cmd.job_id = job.id
          cmd.command = command
          cmd.state = "Pending"
          cmd.job_type = "T"
          cmd.description = "Create template: " + template_name
          cmd.save
        else
          Cmd.capture_template_iland_command(@job, @job.ilandmachine, template_name)
        end
        
        
        if template_region != "iland"
          template.platform = @job.ec2machine.platform
          cmd_result = Cmd.run_cmd(cmd)
          if cmd_result != "Fail" && cmd_result.include?("ami-")
            template.state = "pending"
            template.job_id = job.id
            attrs = cmd_result.split(" ")
            for attr in attrs
              if attr.include?("ami-");
                template.ec2_ami = attr
              end
            end
            if template.ec2_ami != nil && template.ec2_ami.include?("ami-")
              template.save        
              job.state = "Capturing"
              ec2machine = job.ec2machine
              ec2machine.public_dns = ""
              ec2machine.public_ip = ""
              ec2machine.save          
              job.save
              
              redirect_to :action => "show", :controller => "templates", :id => template.id
            else
              flash[:notice] = 'Create template failed, please try again minutes later'
              redirect_to :action => "show", :controller => "jobs", :id => @job_id
            end
          end
        else
          template.platform = @job.ilandmachine.platform
          template.state = "pending"
          template.job_id = job.id
          template.save
          job.state = "Capturing"
          job.save
          redirect_to :action => "show", :controller => "templates", :id => template.id
        end
      end
    end
  end
end
