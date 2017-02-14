class LicenseRequestsController < ApplicationController
  
  def index
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    
    filter = XFilter.new

    search_filter = params[:filter]
    if search_filter && search_filter[:software]
      software_id = search_filter[:software]
      filter.equal software_id, "software_id" 
    end
    
    if search_filter && search_filter[:requester]
      request_id = search_filter[:requester]
      filter.equal request_id, "request_id"
    end

    if search_filter && search_filter[:approver]
      approval_id = search_filter[:approver]
      filter.equal approval_id, "approval_id"
    end

    if search_filter && search_filter[:status]
      status = search_filter[:status]
      filter.equal status, "status"
    end
    if !current_user.is_admin
      filter.equal current_user.id, "request_id"
    end
    @license_requests = LicenseRequest.all(:conditions =>filter.conditions, :order=>["id DESC"])
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @license_requests = @license_requests.paginate  :page => params[:page],:per_page => per_page
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @license_requests }
    end
  end

  def new
    @new_license_request = LicenseRequest.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @new_license_request }
    end
  end

  def add
    software = (Software.find_by_id params[:license_request][:software])
    available_count = software.license_count.to_i - software.get_license_active_count
    request_count = params[:license_request][:count].to_i
    if request_count >0 && !software.nil? && (available_count - request_count)>=0
      @new_license_request = LicenseRequest.new
      @new_license_request.software_id = software.id
      @new_license_request.request_id = params[:license_request][:requester]
      @new_license_request.count = request_count
      @new_license_request.status = "new"
      @new_license_request.save
      Email.mail_to_requester_and_approver_notify_license_status_change(@new_license_request,'created')
      flash[:notice] = "License was successfully requested."
    else
      flash[:notice] = "Failed to request license. There are not enough licenses for you, please contact tech@gdev.com"
    end
    respond_to do |format|
      if can_access('index','license_requests')
        format.html { redirect_to(license_requests_path)}
      else
        format.html { redirect_to(softwares_path) }
      end
      format.xml  { render :xml => @new_license_request, :status => :created, :location => @new_license_request }
    end
  end

  def edit
    unless can_access('edit','license_requests')
      redirect_to license_requests_path
    end
    @edit_license_request=LicenseRequest.find(params[:id])
    if params[:approve] && can_access_license_request(@edit_license_request.id,'approve')
      @edit_license_request.status="active"
      @edit_license_request.approval_id = current_user.id
      @edit_license_request.last_edit_by = current_user.id
      @edit_license_request.save
      Email.mail_to_requester_and_approver_notify_license_status_change(@edit_license_request,'approved')
       respond_to do |format| 
        flash[:notice] = 'License request was successfully approved.'
        format.html { redirect_to (license_requests_path) }
        format.xml  { head :ok }
      end
    elsif params[:close]
      @edit_license_request.status="closed"
      @edit_license_request.last_edit_by = current_user.id
      @edit_license_request.save
       respond_to do |format| 
        flash[:notice] = 'License request was successfully closed.'
        format.html { redirect_to (license_requests_path) }
        format.xml  { head :ok }
      end      
    end
  end
  
  def update
    @edit_license_request=LicenseRequest.find(params[:id])
    puts @edit_license_request.status
    if  params[:license_request][:status] && @edit_license_request.status != params[:license_request][:status]
      case params[:license_request][:status]
      when "new"
        @edit_license_request.approval_id = nil
      when "active"
        @edit_license_request.approval_id = current_user.id
        Email.mail_to_requester_and_approver_notify_license_status_change(@edit_license_request,'approved')
      end
      @edit_license_request.status = params[:license_request][:status]
      @edit_license_request.last_edit_by = current_user.id 
      @edit_license_request.save
      flash[:notice] = 'License request was successfully updated.'
    end
    respond_to do |format| 
      format.html { redirect_to (license_requests_path) }
      format.xml  { head :ok }
    end
  end
  
  def show
    @license_request=LicenseRequest.find(params[:id])
    if !can_access_license_request(@license_request.id,'show')
      flash[:notice] = 'You have no permission to visit this request'
      redirect_to :controller=>"users", :action=>"welcome"
    end
  end

end