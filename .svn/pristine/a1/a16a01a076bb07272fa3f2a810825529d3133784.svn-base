class InstancetypesController < ApplicationController
  # GET /instancetypes
  # GET /instancetypes.xml
  def index
    @instancetypes = Instancetype.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @instancetypes }
    end
  end

  # GET /instancetypes/1
  # GET /instancetypes/1.xml
  def show
    @instancetype = Instancetype.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @instancetype }
    end
  end

  # GET /instancetypes/new
  # GET /instancetypes/new.xml
  def new
    @instancetype = Instancetype.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @instancetype }
    end
  end

  # GET /instancetypes/1/edit
  def edit
    @instancetype = Instancetype.find(params[:id])
  end

  # POST /instancetypes
  # POST /instancetypes.xml
  def create
    @instancetype = Instancetype.new(params[:instancetype])

    respond_to do |format|
      if @instancetype.save
        flash[:notice] = 'Instance type was successfully created.'
        format.html { redirect_to(instancetypes_path) }
        format.xml  { render :xml => @instancetype, :status => :created, :location => @instancetype }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @instancetype.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /instancetypes/1
  # PUT /instancetypes/1.xml
  def update
    @instancetype = Instancetype.find(params[:id])

    respond_to do |format|
      if @instancetype.update_attributes(params[:instancetype])
        flash[:notice] = 'Instance type was successfully updated.'
        format.html { redirect_to(instancetypes_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @instancetype.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /instancetypes/1
  # DELETE /instancetypes/1.xml
  def destroy
    @instancetype = Instancetype.find(params[:id])
    @instancetype.destroy

    respond_to do |format|
      format.html { redirect_to(instancetypes_url) }
      format.xml  { head :ok }
    end
  end
end
