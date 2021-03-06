class SecuritiesController < ApplicationController
  # GET /securities
  # GET /securities.xml
  def index
    @securities = Security.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @securities }
    end
  end

  # GET /securities/1
  # GET /securities/1.xml
  def show
    @security = Security.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @security }
    end
  end

  # GET /securities/new
  # GET /securities/new.xml
  def new
    @security = Security.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @security }
    end
  end

  # GET /securities/1/edit
  def edit
    @security = Security.find(params[:id])
  end

  # POST /securities
  # POST /securities.xml
  def create
    @security = Security.new(params[:security])
    @security.protocol = params[:protocol]
    
    respond_to do |format|
      if @security.save
        flash[:notice] = 'Security was successfully created.'
        format.html { redirect_to(@security) }
        format.xml  { render :xml => @security, :status => :created, :location => @security }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @security.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /securities/1
  # PUT /securities/1.xml
  def update
    @security = Security.find(params[:id])
    @security.protocol = params[:protocol]

    respond_to do |format|
      if @security.update_attributes(params[:security])
        flash[:notice] = 'Security was successfully updated.'
        format.html { redirect_to(@security) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @security.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /securities/1
  # DELETE /securities/1.xml
  def destroy
    @security = Security.find(params[:id])
    @security.destroy

    respond_to do |format|
      format.html { redirect_to(securities_url) }
      format.xml  { head :ok }
    end
  end
end
