class GroupsController < ApplicationController
  # GET /groups
  # GET /groups.xml
  def index
    if current_user.is_admin
      @groups = Group.paginate(:all,:page => params[:page], :per_page => 30)
    else
      @groups = Group.paginate(:all, :conditions => ['manager_id = ?', session[:user]],:page => params[:page], :per_page => 30)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  def update_group_table
      condition = ""
      condition = "name LIKE '%#{params[:query]}%' "
      manager_condition = "name LIKE '%#{params[:query]}%' and manager_id = #{session[:user].id} "
    if current_user.is_admin
      @groups = Group.paginate(:all,:conditions => condition,:page => params[:page], :per_page => 30)
    else
      @groups = Group.paginate(:all,:conditions => manager_condition, :page => params[:page], :per_page => 30)
    end
    render :partial => "list_groups", :layout => false
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    
    @group = Group.find(params[:id])
    ids = []
    index = 0
    @group.users.each do |user|
      ids[index] = user.id
      index += 1
    end
    @users = User.find(:all)
    @users_include = User.find(:all,:conditions=>['id in (?)',ids])
    @users_include.each do |user|
      @users.delete(user)
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  def update_user_group
    group = Group.find(params[:group_id])
    user = User.find(params[:user_id])
    if group.users.include? user
      group.users.delete(user)
      flash[:notice] =user.name + " User is removed from group " + group.name
    else
      group.users  << user
      flash[:notice] = user.name + " User is added to group " + group.name
    end
    group.save
    render :text=>flash[:notice]
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /groups
  # POST /groups.xml
  def create
    #    render :text =>'<pre>aaaaaaaaaaaa'+params.to_yaml and return
    @group = Group.new(params[:group])
    respond_to do |format|
      if @group.save
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to(groups_path) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])
    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to(groups_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end
end
