class SecuritygroupsController < ApplicationController
  # GET /securitygroups
  # GET /securitygroups.xml
  def index
    @securitygroups = Securitygroup.find(:all)
    @user = current_user
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @securitygroups }
    end
  end

  # GET /securitygroups/1
  # GET /securitygroups/1.xml
  def show
    @securitygroups = Securitygroup.find(:all)
    @securitygroup = Securitygroup.find(params[:id])
    @securities = @securitygroup.securities
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @securitygroups }
    end
  end
  
  def selectport
    @securitygroups = Securitygroup.find(:all)
    @securitygroup = Securitygroup.find(params[:id])
    @securities = Security.find(:all)
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @securitygroup }
    end
  end
  
  def update_securitygroups_port
    securitygroup = Securitygroup.find(params[:securitygroup_id])
    security = Security.find(params[:security_id])
    
    if securitygroup.securities.include? security
      securitygroup.securities.delete(security)
      flash[:notice] = "Security Port is removed from Securitygroup " 
    else
      securitygroup.securities << security
      flash[:notice] = "Security Port is added to Securitygroup " 
    end
    security.save
    render :text=>flash[:notice]
  end

  # GET /securitygroups/new
  # GET /securitygroups/new.xml
  def new
    @securitygroup = Securitygroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @securitygroup }
    end
  end
  

  # GET /securitygroups/1/edit
  def edit
    @securitygroup = Securitygroup.find(params[:id])
  end

  # POST /securitygroups
  # POST /securitygroups.xml
  def create
    @securitygroup = Securitygroup.new(params[:securitygroup])

    respond_to do |format|
      if @securitygroup.save
        flash[:notice] = 'Securitygroup was successfully created.'
        format.html { redirect_to(securitygroups_path) }
        format.xml  { render :xml => @securitygroup, :status => :created, :location => @securitygroup }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @securitygroup.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /securitygroups/1
  # PUT /securitygroups/1.xml
  def update
    @securitygroup = Securitygroup.find(params[:id])

    respond_to do |format|
      if @securitygroup.update_attributes(params[:securitygroup])
        flash[:notice] = 'Securitygroup was successfully updated.'
        format.html { redirect_to(securitygroups_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @securitygroup.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /securitygroups/1
  # DELETE /securitygroups/1.xml
  def destroy
    @securitygroup = Securitygroup.find(params[:id])
    @securitygroup.destroy

    respond_to do |format|
      format.html { redirect_to(securitygroups_url) }
      format.xml  { head :ok }
    end
  end
  
  
end
