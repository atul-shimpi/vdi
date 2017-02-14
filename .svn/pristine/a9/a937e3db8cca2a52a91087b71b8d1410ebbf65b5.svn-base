require "yaml"
class EbsvolumesController < ApplicationController
  def index
    if current_user.is_admin
      @ebsvolumes = Ebsvolume.find(:all, :order=> "id DESC")
    else
      @ebsvolumes = Ebsvolume.find(:all, :conditions=>"user_id = #{current_user.id}", :order=> "id DESC")
    end        
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @ebsvolumes = @ebsvolumes.paginate  :page => params[:page],:per_page => per_page
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ebsvolumes }
    end    
  end
  
  def show
    @ebsvolume = Ebsvolume.find(params[:id])
    if !@ebsvolume.can_access_ebsvolume(current_user)
      flash[:notice] = 'You have no permission to visit this ebs'
      redirect_to :action => 'welcome',:controller=>'users'
      return      
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ebsvolume }
    end
  end
  
  def edit
    @ebsvolume = Ebsvolume.find(params[:id])
    if !@ebsvolume.can_access_ebsvolume(current_user)
      flash[:notice] = 'You have no permission to visit this ebs'
      redirect_to :action => 'welcome',:controller=>'users'
      return      
    end
  end

  def new
    @ebsvolume = Ebsvolume.new
    @snapshot_id = params[:snapshot_id]
    @region = params[:region]
    
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    @regions = config["regions"].split(",")    
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ebsvolume }
    end
  end
  def update
    @ebsvolume = Ebsvolume.find(params[:id])
    respond_to do |format|
      if @ebsvolume.update_attributes(params[:ebsvolume])
        flash[:notice] = 'EBS Volume was successfully updated.'
        format.html { redirect_to :action => "show", :id => @ebsvolume.id }
        format.xml  { head :ok }
      else
        flash[:notice] = 'EBS Volume update failed.'
        format.html { redirect_to :action => "show", :id => @ebsvolume.id }
        format.xml  { head :ok }
      end
    end
  end
  
  def create
    @ebsvolume = Ebsvolume.new(params[:ebsvolume])
    @ebsvolume.user_id = current_user.id
    snapshot_id = params[:snapshot_id]
    if (snapshot_id && !snapshot_id.blank?)
      @ebsvolume.snapshot_id = snapshot_id if (snapshot_id && !snapshot_id.blank?)
    end
    if !@ebsvolume.region || @ebsvolume.region.blank?      
      flash[:notice] = 'Region should not empty'
      redirect_to :action => 'welcome',:controller=>'users'
      return    
    end      
    result = Ebsvolume.create(@ebsvolume)

    respond_to do |format|
      if result != "Fail"
        flash[:notice] = 'Ebsvolume was successfully created.'
        format.html { redirect_to(ebsvolumes_path) }
        format.xml  { render :xml => @ebsvolume, :status => :created, :location => @ebsvolume }
      else
        flash[:notice] = 'Ebsvolume was failed to create'
        format.html { render :action => "new" }
        format.xml  { render :xml => @ebsvolume.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @ebsvolume = Ebsvolume.find(params[:id])
    result = Ebsvolume.delete(@ebsvolume)
    
    respond_to do |format|
      if result != "Fail"
        flash[:notice] = 'Ebsvolume was successfully deleted'
      else 
        flash[:notice] = 'Ebsvolume was failed to delete'
      end
      format.html { redirect_to :action => "show", :id => @ebsvolume.id }
      format.xml  { head :ok }
    end
  end
  
  def attach
    @ebsvolume = Ebsvolume.find(params[:id])
    if params[:submit] != nil
      @ebsvolume.attach_device = params[:attach_device]

      job_id = params[:job_id]
      is_job_valid = true
      if !job_id || job_id.strip.length == 0 || (job_id.gsub(/[0-9]*/,"")).strip.length != 0
        flash[:notice] = 'VDI job id should be a number'  
        is_job_valid = false
      else
        job = Job.find(job_id)
        if job == nil || !(job.state = "Run" || job.state = "PowerOFF") || !job.ec2machine
          flash[:notice] = 'The job is not valid for attach, it should be a Run or PowerOFF job'  
          is_job_valid = false        
        end
      end
      if is_job_valid == false
        redirect_to :action => "attach", :id => @ebsvolume.id
        return
      end
      @ebsvolume.job_id = job_id
      @ebsvolume.instance_id = job.ec2machine.instance_id
      @ebsvolume.save
      result = Ebsvolume.attach(@ebsvolume)
      if result == "Fail"
        flash[:notice] = 'Attach the volume failed'  
      else 
        flash[:notice] = 'Attach the volume successfully'  
      end
      redirect_to :action => "show", :id => @ebsvolume.id
    end
  end
  
  def detach
    @ebsvolume = Ebsvolume.find(params[:id])
    result = Ebsvolume.detach(@ebsvolume)
    
    if result == "Fail"
      flash[:notice] = 'Detach the volume failed'  
    else 
      flash[:notice] = 'Detach the volume successfully'  
    end
    
    redirect_to :action => "show", :id => @ebsvolume.id
  end
end