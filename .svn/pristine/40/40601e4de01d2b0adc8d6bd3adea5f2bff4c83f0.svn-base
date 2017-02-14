class SoftwaresController < ApplicationController
  
  def index
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    
    filter = XFilter.new

    search_name = params[:search_name]
    if search_name != nil && search_name.strip != ""
        filter.like search_name.strip, "name"
    end
    search_filter = params[:filter]
    
    @available_filter =""
    @available_filter = search_filter[:available] if search_filter && search_filter[:available]

    if search_filter && search_filter[:isfree]
      is_free = search_filter[:isfree]
      puts is_free
        if is_free == "free"
          filter.equal 1, "is_free"
        elsif is_free == "not free"
          filter.equal 0, "is_free"
        end
    end
    
    @softwares = Software.all(:conditions =>filter.conditions, :order=>["id DESC"])
#    puts @softwares.size 
#    puts "conditions: ",filter.conditions
#    puts
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @softwares = @softwares.paginate  :page => params[:page],:per_page => per_page
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @softwares }
    end
  end
  
  # GET /softwares/new
  # GET /softwares/new.xml
  def new
    @new_software = Software.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @new_software }
    end
  end
  
  def add
    software_name = params[:software][:name]
    software_version = params[:software][:version]
    software = Software.find(:first,:conditions=>["name= '#{software_name}' and version = '#{software_version}'"])
    @new_software = Software.new(params[:software])
    unless software
      @new_software.license_count=0 if @new_software.license_count.nil? || @new_software.license_count<0
      @new_software.is_free = params[:software][:is_free]=="free" ? true : false
      result = @new_software.save
    end
    if !result
      respond_to do |format|
#        if @new_software.license_count<0
#          flash[:notice] = 'License amount can\'t be negative.'
#        else
          flash[:notice] = 'Software already exists. Name:' + software.name + ' Version: ' + software.version
#        end
        format.html { render :action => "new" }
        format.xml  { render :xml => @new_software.errors, :status => :unprocessable_entity }
      end
    else        
      respond_to do |format|
        flash[:notice] = 'Software was successfully created.'
        format.html { redirect_to(softwares_path) }
        format.xml  { render :xml => @new_software, :status => :created, :location => @new_software }
      end
    end
  end

  def edit
    unless can_access('edit','softwares')
      redirect_to softwares_path
    end
    @edit_software=Software.find(params[:id])
  end
  
  def update
    @edit_software=Software.find(params[:id])
    license_active_count = @edit_software.get_license_active_count
    respond_to do |format|
      if @edit_software.update_attributes(params[:software])
        @edit_software.license_count=license_active_count if @edit_software.license_count.nil? || @edit_software.license_count<license_active_count
        @edit_software.is_free = params[:software][:is_free]
        @edit_software.save 
        flash[:notice] = 'Software was successfully updated.'
        format.html { redirect_to (softwares_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @edit_software.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def license_detail
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    @software = Software.find_by_id params[:id]
    @job_licenses = Job.all(:joins=>["LEFT JOIN templates tp ON jobs.template_id = tp.id LEFT JOIN templates_softwares tp_sft ON tp.id = tp_sft.template_id"],:conditions=>["jobs.state IN ('Deploying','Open','PowerOFF','Run') AND tp_sft.software_id = ?",@software.id])
    @user_licenes = LicenseRequest.all(:conditions=>["software_id = ?",@software.id],:order=>"status")
    per_page = config["per_page"]
    @job_licenses = @job_licenses.paginate  :page => params[:page],:per_page => per_page
    @user_licenes = @user_licenes.paginate  :page => params[:page],:per_page => per_page
  end
  
  def show
    @software = Software.find_by_id params[:id]
  end
  


end