require "yaml"
class ElasticipsController < ApplicationController
  def index
    if current_user.is_admin
      @elasticips = Elasticip.find(:all, :order=> "id DESC")
    else
      @elasticips = Elasticip.find(:all, :conditions=>"user_id = #{current_user.id}", :order=> "id DESC")
    end        
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @elasticips = @elasticips.paginate  :page => params[:page],:per_page => per_page
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @elasticips }
    end    
  end
  
  def show
    @elasticip = Elasticip.find(params[:id])
    if !@elasticip.can_access_elasticip(current_user)
      flash[:notice] = 'You have no permission to visit this ebs'
      redirect_to :action => 'welcome',:controller=>'users'
      return      
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @elasticip }
    end
  end
  
  def edit
    @elasticip = Elasticip.find(params[:id])
    if !@elasticip.can_access_elasticip(current_user)
      flash[:notice] = 'You have no permission to visit this ebs'
      redirect_to :action => 'welcome',:controller=>'users'
      return      
    end
  end

  def new
    @elasticip = Elasticip.new
    @region = params[:region]
    
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    @regions = config["regions"].split(",")    
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @elasticip }
    end
  end
  def update
    @elasticip = Elasticip.find(params[:id])
    respond_to do |format|
      if @elasticip.update_attributes(params[:elasticip])
        flash[:notice] = 'Elastic IP was successfully updated.'
        format.html { redirect_to :action => "show", :id => @elasticip.id }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Elastic IP update failed.'
        format.html { redirect_to :action => "show", :id => @elasticip.id }
        format.xml  { head :ok }
      end
    end
  end
  
  def create
    @elasticip = Elasticip.new(params[:elasticip])
    @elasticip.user_id = current_user.id
    if !@elasticip.blank?
      region = params[:region]
      result = Elasticip.create(@elasticip)
    else
        flash[:notice] = 'Region should not empty'
        redirect_to :action => 'welcome',:controller=>'users'
        return  
    end
    respond_to do |format|
      if result != "Fail"
        flash[:notice] = 'Elasticip was successfully created.'
        format.html { redirect_to(elasticips_path) }
        format.xml  { render :xml => @elasticip, :status => :created, :location => @elasticip }
      else
        flash[:notice] = 'Elasticip was failed to create'
        format.html { render :action => "new" }
        format.xml  { render :xml => @elasticip.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @elasticip = Elasticip.find(params[:id])
    if @elasticip.is_attached
      flash[:notice] = "Can't delete attached Ip"
      redirect_to :action => "show", :id => @elasticip.id
      return
    end
    result = Elasticip.delete(@elasticip)
    
    respond_to do |format|
      if result != "Fail"
        flash[:notice] = 'Elasticip was successfully deleted'
      else 
        flash[:notice] = 'Elasticip was failed to delete'
      end
      format.html { redirect_to :action => "show", :id => @elasticip.id }
      format.xml  { head :ok }
    end
  end
  
  def attach
    @elasticip = Elasticip.find(params[:id])
    if params[:submit] != nil

      job_id = params[:job_id]
      is_job_valid = true
      if !job_id || job_id.strip.length == 0 || (job_id.gsub(/[0-9]*/,"")).strip.length != 0
        flash[:notice] = 'VDI job id should be a number'  
        is_job_valid = false
      else
        job = Job.find(job_id)
        if job == nil || !(job.state = "Run") || !job.ec2machine
          flash[:notice] = 'The job is not valid for attach, it should be a Run job'  
          is_job_valid = false        
        end
      end
      if is_job_valid == false
        redirect_to :action => "attach", :id => @elasticip.id
        return
      end
      @elasticip.job_id = job_id
      @elasticip.instance_id = job.ec2machine.instance_id
      @elasticip.save
      result = Elasticip.attach(@elasticip)
      if result == "Fail"
        flash[:notice] = 'Attach the volume failed'  
      else 
        flash[:notice] = 'Attach the volume successfully'  
      end
      redirect_to :action => "show", :id => @elasticip.id
    end
  end
  
  def detach
    @elasticip = Elasticip.find(params[:id])
    result = Elasticip.detach(@elasticip)
    
    if result == "Fail"
      flash[:notice] = 'Detach the volume failed'  
    else 
      flash[:notice] = 'Detach the volume successfully'  
    end
    
    redirect_to :action => "show", :id => @elasticip.id
  end
end