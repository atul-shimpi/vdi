class UsersController < ApplicationController

  layout "application",:except=>[:textlogin, :login]
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :list }

  #Login method. Store the user's information in session
  def login
    if request.post?
      if session[:user] = User.authenticate(params[:user][:account], params[:user][:password])
        session[:original_user] = current_user
        # Track the user login
        current_user.last_login_on = Time.now()
        current_user.save()
        flash[:notice]  = "Login successful"
        if session[:ori_request_url] != nil
        	ori_request_url = session[:ori_request_url]
        	session[:ori_request_url] = nil
        	redirect_to ori_request_url
        else
        	redirect_to :action => "welcome"
        end
      else
        flash[:notice] = "Login Unsuccessful"
      end
    else
      render :layout => 'login'
    end
  end
  
  def textlogin
    if session[:user] = User.authenticate(params[:account],params[:password])
#        session[:group] = User.find(:first,:conditions=>{:id=>session[:user].group_id})
      session[:original_user] = session[:user]
      #Login successful
      @result = 0
    else
      #Login failed
      @result = 1
    end
  end

  #Logout method. Clear the session
  def logout
    session[:user]=nil
    session[:original_user]=nil
    session[:project]=nil
    session[:submission]=nil
    redirect_to :action => "login"
  end

  def index
    @roles = Role.find :all
    condition = ""
    if params[:query]!=nil && params[:query]!=''
      condition = "name LIKE '%#{params[:query]}%' "
    end
    if condition.length == 0
      @users = User.paginate :page => params[:page], :per_page => 30
    else
      @users = User.paginate :page => params[:page], :conditions => condition, :per_page => 30
    end
    if request.xml_http_request?
      render :partial => "list_users", :layout => false
    end
  end

  # Show Welcome Page for the current user
  def welcome
    @instance_types = Instancetype.find(:all)
  end

  # Create new user. Only can be accessed by group account
  def new
  end

  # A single point of contact for the Admin to administer all the users
  def createuser
    @new_user = User.new
    @new_user.account = params[:new_user][:account]
    @new_user.name = params[:new_user][:name]
    @new_user.email = params[:new_user][:email]
    if params[:new_user][:password] != params[:new_user][:confirmpassword]
      @new_user.errors.add "The passwords donot match"
    else
      @new_user.password = User.encrypt(params[:new_user][:password])
    end

    # Add the user to a group
#    usergroupself = false
#    @usergroup = User.find params[:usergroup][:id] unless params[:usergroup][:id] == ""
#    if @usergroup.nil? || @usergroup.id != @usergroup.group_id # If the group is not a group or the group doesnot exist
#      flash[:notice] = "The User is being made as a group"
#      usergroupself = true ;
#      # @new_user.group = @new_user # make this user the group
#    else
#      @new_user.group = @usergroup # make the user belong to a group
#    end
    @role = Role.find params[:role][:id]

    if @role.nil?
      flash[:notice] = "The user doesnot have any roles"
      render :action => 'new'
      return
    else
      @new_user.roles << @role
    end
    @partner = nil

    if !( @partner.nil? || !@partner.is_partner )
      @new_user.partners << @partner
    end
    if !@new_user.save # If the basic user credentials could not be saved
      flash[:notice] = "The user's Data could not be saved"
      render :action => 'new'
    else

        @new_user.save

      flash[:notice] = "User was successfully created"
      redirect_to :action => 'index'
    end
  end

  def edituser
    @new_user = User.find params[:id]
    @role = @new_user.roles.first
    @usergroup = @new_user.group
#    @partner = @new_user.partners.length == 0 ? nil : @new_user.partners.first
  end

  def updateuser
    @new_user = User.find params[:id]
    @new_user.account = params[:new_user][:account]
    @new_user.name = params[:new_user][:name]
    @new_user.email = params[:new_user][:email]
    can_update = true ;
    if params[:new_user][:password] != ""
      if params[:new_user][:password] != params[:new_user][:confirmpassword]
        flash[:notice] = "The passwords donot match"
        can_update = false ;
      else
        @new_user.password = User.encrypt(params[:new_user][:password])
      end
    end
    @role = Role.find params[:role][:id]
    if @role.nil?
      flash[:notice] = "The user doesnot have any roles"
      can_update = false
    else
      @new_user.roles = [ @role ]
    end
    @partner = nil
    if can_update
      if !@new_user.save # If the basic user credentials could not be saved
        flash[:notice] = "The user's Data could not be saved"
        render :action => 'edituser'
      else
        flash[:notice] = "User was successfully updated"
        redirect_to :action => 'index'
      end
    else
      render :action => 'edituser'
    end
  end

  # Edit the profile of the current user
  def edit

  end

  def update
    @user = User.find(@user.id)
    new_password = params[:user][:new_password]
    confirm_password = params[:user][:confirm_password]
    can_update = true
    if new_password!=nil && new_password!=''
      if new_password.eql?confirm_password
        @user.password = User.encrypt(new_password)
      else
        flash[:notice] = 'Passwords entered do not match!'
        render :action => 'edit'
        can_update = false
      end
    end
    if can_update
      @user.name = params[:user][:name]
      @user.email = params[:user][:email]
      @user.location = params[:user][:location]
      if @user.save
        session[:user]=@user
        flash[:notice] = 'User was successfully updated.'
        redirect_to :action => 'welcome'
      else
        render :action => 'edit'
      end
    end
  end

  # Update the roles for user/group. This method is called by remote_link.
  def update_role
    @role = Role.find(params[:role])
    @update_user = User.find(params[:user])
    if @update_user.roles.include? @role
      @update_user.removeRole(@role)
      flash[:notice] =@role.role_name + " role is removed from " + @update_user.name
    else
      @update_user.addRole(@role)
      flash[:notice] =@role.role_name + " role is added to " + @update_user.name
    end
    @update_user.save

    render :text=>flash[:notice]
  end

  # Delete the user. This method is called by remote_link
  def destroy
    @deleted_user = User.find(params[:id])
    @users = User.find(params[:users])
    @deleted_user.destroy
    @users.delete(@deleted_user)
    @roles = Role.find(params[:roles])
    render :partial => "list_users", :layout => false
  end

  # disable the account of that user
  def disable_user
    user = User.find(params[:id])
    user.disabled = 1

    if !user.save # If the basic user credentials could not be saved
      flash[:notice] = "Failed to disable this user."
      redirect_to :action => 'index'
    else
      flash[:notice] = "Disable user successfully."
      redirect_to :action => 'index'
    end
  end


  # enable the account of that user
  def enable_user
    user = User.find(params[:id])
    user.disabled = 0

    if !user.save # If the basic user credentials could not be saved
      flash[:notice] = "Failed to enable this user."
      redirect_to :action => 'index'
    else
      flash[:notice] = "Enable user successfully."
      redirect_to :action => 'index'
    end
  end

end


private

def get_score_by_rating(rating1,rating2,rating3,rating4,rating5,weightage,score,value)
  if value >= rating1
    score = score + 5*weightage
  elsif value >= rating2 && value < rating1
    score = score + 4*weightage
  elsif value >= rating3 && value < rating2
    score = score + 3*weightage
  elsif value >= rating4 && value < rating3
    score = score + 2*weightage
  elsif value < rating4 && value >= rating5
    score = score + 1*weightage
  end
  return score
end

def sort_hash(in_hash)
  out_hash = {}
  @array = []
  for hash in in_hash
    @array << (hash[1].to_f + 10000.00001).to_s + '=>' + hash[0].to_s
  end
  @array = @array.sort.reverse!
  i = 1
  last_sort = 0
  last_value = 0
  for a in @array do
    name_and_value = a.split('=>')
    if (name_and_value[0].to_f - 10000.00001) != last_value
      last_sort = i
    end
    out_hash[name_and_value[1]] = [name_and_value[0].to_f - 10000.00001,last_sort]
    i = i + 1
    last_value = name_and_value[0].to_f - 10000.00001
  end
  return out_hash
end
