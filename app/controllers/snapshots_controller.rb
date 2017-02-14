class SnapshotsController < ApplicationController
  def index
    if current_user.is_admin
      @snapshots = Snapshot.find(:all, :order=> "id DESC")
    else
      @snapshots = Snapshot.find(:all, :conditions=>"user_id = #{current_user.id}", :order=> "id DESC")
    end        
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    @snapshots = @snapshots.paginate  :page => params[:page],:per_page => per_page
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @snapshots }
    end   
  end
  
  def show
    @snapshot = Snapshot.find(params[:id])
    if !@snapshot.can_access_snapshot(current_user)
      flash[:notice] = 'You have no permission to visit this snapshot'
      redirect_to :action => 'welcome',:controller=>'users'
      return      
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @snapshot }
    end    
  end
  
  def edit
    @snapshot = Snapshot.find(params[:id])
    if !@snapshot.can_access_snapshot(current_user)
      flash[:notice] = 'You have no permission to visit this snapshot'
      redirect_to :action => 'welcome',:controller=>'users'
      return      
    end    
  end

  def new
    @snapshot = Snapshot.new
    @ebsvolume_id = params[:ebsvolume_id]
    @region = params[:region]
    @job_id = params[:job_id]
    if !@ebsvolume_id || @ebsvolume_id.blank?
      flash[:notice] = 'You should take a snapshot from an EBS Volume'
      redirect_to :action => 'welcome',:controller=>'users'
      return                
    end
    if !@region || @region.blank?
      flash[:notice] = 'You should specify the region'
      redirect_to :action => 'welcome',:controller=>'users'
      return                
    end    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @snapshot }
    end    
  end
  def update
    @snapshot = Snapshot.find(params[:id])
    respond_to do |format|
      if @snapshot.update_attributes(params[:snapshot])
        flash[:notice] = 'snapshot was successfully updated.'
        format.html { redirect_to :action => "show", :id => @snapshot.id }
        format.xml  { head :ok }
      else
        flash[:notice] = 'snapshot update failed.'
        format.html { redirect_to :action => "show", :id => @snapshot.id }
        format.xml  { head :ok }
      end
    end
  end
  
  def create
    @snapshot = Snapshot.new(params[:snapshot])
    volume_id = params[:volume_id]
    region = params[:region]
    @snapshot.job_id = params[:job_id]
    if !volume_id || volume_id.blank?
      flash[:notice] = 'Volume is not specified'
      redirect_to :action => 'welcome',:controller=>'users'     
    end
    @snapshot.volume_id = volume_id

    if !region || region.blank?
      flash[:notice] = 'Region is not specified'
      redirect_to :action => 'welcome',:controller=>'users'     
    end
    @snapshot.region = region
    @snapshot.user_id = current_user.id
    result = Snapshot.create(@snapshot)
    respond_to do |format|
      if result != "Fail"
        flash[:notice] = 'Snapshot was successfully created.'
        format.html { redirect_to(snapshots_path) }
        format.xml  { render :xml => @snapshot, :status => :created, :location => @snapshot }
      else
        flash[:notice] = 'Snapshot was failed to create.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @snapshot.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @snapshot = Snapshot.find(params[:id])
    result = Snapshot.delete(@snapshot)
    respond_to do |format|
      if result != "Fail"
        flash[:notice] = 'Snapshot was successfully removed'
      else
        flash[:notice] = 'Snapshot was failed to remove'
      end
      format.html { redirect_to :action => "show", :id => @snapshot.id }
      format.xml  { head :ok }
    end
  end
end