# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include ApplicationHelper

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '020839c7d11ccf295b192209a4e7aaed'
  protect_from_forgery :only => [:destroy]
  before_filter :authorize,:except =>['login','textlogin','update_time','footer','rolemapping','checklock','updatelock','initialcommand', 
               'demodeploy', 'product_logo', 'creat_demo_job','demo_job_deployed', 'undeployJobByInstanceID', 'set_param', 'get_param']

  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  private

  # Authorize method for access control. User can access the actions in his role's action list.
  # If the target action is not listed, user will receive a no permission message and be redirected
  # to the welcome page.
  # Admin group can access every page.
  def authorize
    @user = session[:user]
    @group = session[:group]
    @original_user = session[:original_user]
    if @user.nil? || @original_user.nil?
      flash[:notice]= "Please login"
      session[:ori_request_url] =  request.request_uri
      redirect_to root_path
    else
      if !can_access(params[:action],params[:controller])
        flash[:notice] = 'you have no permission to visit this page ' + params[:action]+' '+params[:controller]
        redirect_to root_path
      end
    end
  end
end
