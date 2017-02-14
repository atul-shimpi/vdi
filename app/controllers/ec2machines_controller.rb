class Ec2machinesController < ApplicationController
  # GET /ec2machines
  # GET /ec2machines.xml
  def index
    @ec2machines = Ec2machine.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ec2machines }
    end
  end

  # GET /ec2machines/1
  # GET /ec2machines/1.xml
  def show
    @ec2machine = Ec2machine.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ec2machine }
    end
  end

  # GET /ec2machines/new
  # GET /ec2machines/new.xml
  def new
    @ec2machine = Ec2machine.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ec2machine }
    end
  end

  # GET /ec2machines/1/edit
  def edit
    @ec2machine = Ec2machine.find(params[:id])
  end

  # POST /ec2machines
  # POST /ec2machines.xml
  def create
    @ec2machine = Ec2machine.new(params[:ec2machine])

    respond_to do |format|
      if @ec2machine.save
        flash[:notice] = 'Ec2machine was successfully created.'
        format.html { redirect_to(ec2machines_path) }
        format.xml  { render :xml => @ec2machine, :status => :created, :location => @ec2machine }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ec2machine.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ec2machines/1
  # PUT /ec2machines/1.xml
  def update
    @ec2machine = Ec2machine.find(params[:id])

    respond_to do |format|
      if @ec2machine.update_attributes(params[:ec2machine])
        flash[:notice] = 'Ec2machine was successfully updated.'
        format.html { redirect_to(ec2machines_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ec2machine.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ec2machines/1
  # DELETE /ec2machines/1.xml
  def destroy
    @ec2machine = Ec2machine.find(params[:id])
    @ec2machine.destroy

    respond_to do |format|
      format.html { redirect_to(ec2machines_url) }
      format.xml  { head :ok }
    end
  end
end
