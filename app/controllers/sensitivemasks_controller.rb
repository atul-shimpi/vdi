class SensitivemasksController < ApplicationController
  # GET /sensitivemasks
  # GET /sensitivemasks.xml
  def index
    @sensitivemasks = Sensitivemask.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sensitivemasks }
    end
  end

  # GET /sensitivemasks/1
  # GET /sensitivemasks/1.xml
  def show
    @sensitivemask = Sensitivemask.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sensitivemask }
    end
  end

  # GET /sensitivemasks/new
  # GET /sensitivemasks/new.xml
  def new
    @sensitivemask = Sensitivemask.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sensitivemask }
    end
  end

  # GET /sensitivemasks/1/edit
  def edit
    @sensitivemask = Sensitivemask.find(params[:id])
  end

  # POST /sensitivemasks
  # POST /sensitivemasks.xml
  def create
    @sensitivemask = Sensitivemask.new(params[:sensitivemask])
    
    respond_to do |format|
      if @sensitivemask.save
        flash[:notice] = 'Sensitivemask was successfully created.'
        format.html { redirect_to(@sensitivemask) }
        format.xml  { render :xml => @sensitivemask, :status => :created, :location => @sensitivemask }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sensitivemask.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sensitivemasks/1
  # PUT /sensitivemasks/1.xml
  def update
    @sensitivemask = Sensitivemask.find(params[:id])

    respond_to do |format|
      if @sensitivemask.update_attributes(params[:sensitivemask])
        flash[:notice] = 'Sensitivemask was successfully updated.'
        format.html { redirect_to(@sensitivemask) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sensitivemask.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sensitivemasks/1
  # DELETE /sensitivemasks/1.xml
  def destroy
    @sensitivemask = Sensitivemask.find(params[:id])
    @sensitivemask.destroy

    respond_to do |format|
      format.html { redirect_to(sensitivemasks_url) }
      format.xml  { head :ok }
    end
  end
end
