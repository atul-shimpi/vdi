class RolesController < ApplicationController
  def index
    @user =session[:user]
    @roles = Role.find(:all)
    if params[:role]==nil || params[:role][:id]==nil
      @role = Role.find(:first)
    else
      @role = Role.find(params[:role][:id])
    end
  end

  def update_role_action
    role = Role.find(params[:role_id])
    action = Action.find(params[:action_id])
    if role.actions.include? action
      role.actions.delete(action)
      flash[:notice] =action.description + " Action is removed from role " + role.role_name
    else
      role.actions  << action
      flash[:notice] = action.description + " Action is added to role " + role.role_name
    end
    role.save
    render :text=>flash[:notice]
  end
  # GET /services/new
  # GET /services/new.xml
  def new
    @role = Role.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @service }
    end
  end

  # GET /services/1/edit
  def edit
    @role = Role.find(params[:id])
  end

  # POST /services
  # POST /services.xml
  def create
    role = Role.new(params[:role])
    role.parent_role = Role.find(:first,:conditions=>{:role_name=>"admin"}).id
    if role.save
      flash[:notice] = 'Role was successfully created.'
      redirect_to :action =>'index'
    end
  end

  # PUT /services/1
  # PUT /services/1.xml
  def update
    @role = Role.find(params[:id])

    respond_to do |format|
      if @service.update_attributes(params[:service])
        flash[:notice] = 'Service was successfully updated.'
        format.html { redirect_to(@service) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @service.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /services/1
  # DELETE /services/1.xml
  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(services_url) }
      format.xml  { head :ok }
    end
  end
end
