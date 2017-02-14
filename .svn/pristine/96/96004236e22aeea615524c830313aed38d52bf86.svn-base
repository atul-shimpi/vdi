require 'fastercsv'
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def current_user
    session[:user]
  end

  def original_user
    if session[:original_user] == nil
      session[:original_user] = session[:user]
    end
    session[:original_user]
  end

  def get_user_ip
    return "#{request.remote_ip()}"
  end
  
  # Give style class to the special column which is sorted
  # @param should corrospond to a database table column
  def sort_td_class_helper(param)
    result = 'class="sortup"' if params[:sort] == param
    result = 'class="sortdown"' if params[:sort] == param + "_reverse"
    return result
  end

  # Create a sortable column head
  # @text: The display text of the link
  # @param: The databse table column name
  # @action: The action to refresh the table view
  def sort_link_helper(text,param,action)
    key = param
    key += "_reverse" if params[:sort] == param
    options = {
      :url => {:action => action, :params => params.merge({:sort => key, :page => nil})},
      :method=>"POST"
    }
    html_options = {
      :title => "Sort by this field",
      :href => url_for(:action => 'list', :params => params.merge({:sort => key, :page => nil})),
      :class=> "sort"
    }
    link_to(text, options, html_options)
  end

  # Convert the param name to SQL language
  def sort_sql_helper(param)
    return param.gsub('_reverse'," DESC")
  end

  def mask_sensitive_string(s)
    temp = s
    sensitives = Sensitivemask.find(:all)
    sensitives.each do |sensitive|
      if !sensitive.sensitive_string.blank?
        temp = temp.gsub(sensitive.sensitive_string, sensitive.mask_string)
      end
    end 
    return temp
  end

  # Add a condition field to link_to method,
  # so that the link can be displayed or not according to the condition.
  def link_if(condition, name, options = {}, html_options = {})
    if condition
      link_to(name, options, html_options)
    end
  end

  def can_access(action,controller)
    user = session[:user]
    if user.is_admin
      return true
    end
    if user == nil && action!='login'
      return false
    else
      if action=='welcome'  ||
          action=='logout'  ||
          (action=='edit' && controller=='user') ||
          (action=='capturetemplate' && controller=='templates') ||
          (action=='rolemapping' || action=='checklock' || action=='updatelock' && controller=='clusters')  ||
          (action=='initialcommand' && controller=='jobs')
        return true
      end
      #action_to_do = Action.find(:first,:conditions=>{:action=>action,:controller=>controller})
      for role in user.roles do
        if !role.actions.detect { |a| a.action  == action && a.controller == controller }.nil? #include?action_to_do
          return true
        end
      end
      return false
    end
  end

  def can_access_license_request(license_request_id,action)
    license_request = LicenseRequest.find(license_request_id)
    user = session[:user]
    case action
    when 'show', 'close'
      if user.is_admin || user.id == license_request.request_id
          return true
      end
    when 'approve'
      if user.is_admin
        return true
      end
    else
      return true if can_access(action,'license_requests')
      return false
    end
  end

  def get_next_saturday(time)
    if time==nil
      time=0
    end
    time = Time.at(time)
    add_day = (6 + 7 - time.wday) % 7
    if add_day == 0
      add_day =7
    end
    time = time - time.to_i % (24*60*60)
    saturday = time + add_day*24*60*60

    return saturday
  end

  def get_this_friday
    today = Time.parse("00:00")
    add_day = (5 + 7 - today.wday) % 7
    friday = today + add_day*24*60*60

    return friday
  end

  # checks if the RFP creation team has crossed the deadline for the current week
  #def isBeforeRfpCreationDeadline
  #timeline = Time.now
  #timeline.wday < 3 || ( timeline.wday == 3 && timeline.hour < 6 )
  #end

  def get_current_time
    now =Time.now()
    return now.strftime("%Y-%m-%d %H:%M:%S")
  end

  def get_target_time(base_time,duration,timeline,flag=nil)
    if base_time.hour == 0 && base_time.min == 0 && base_time.sec == 0
      duration = duration - 1
    end
    expected_at = base_time
    if flag
      expected_at = expected_at + timeline*3600
    end
    if duration != 0
      duration.times do
        if expected_at.wday == 5 || expected_at.wday == 6
          expected_at +=(8-expected_at.wday)*24*3600
        else
          expected_at +=24*3600
        end
      end
    else
      if expected_at.wday == 6
        expected_at +=2*24*3600
      elsif expected_at.wday == 0
        expected_at +=24*3600
      end
    end
    if !flag
      expected_at = expected_at.at_beginning_of_day + timeline*3600
    end
    if expected_at.wday == 1 && expected_at.hour == 0 && expected_at.min == 0 && expected_at.sec == 0
      expected_at = expected_at - 2*24*3600
    end
    return expected_at
  end
end

# uses view tabs inside application layout
def view_tabs(controller,action)

  html = ""
  if (controller == 'users'&& action== 'index') || (controller=='roles'&& action == 'index') || (controller=='groups'&& action == 'index')
   html  = <<HTML
        <div class="jqueryslidetab"  style="width:1024px;">
          <ul>
            <li> #{link_if can_access('index','users'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Users', :action => 'index' ,:controller=>"users"}</li>
            <li>#{link_if can_access('index','roles'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Roles', :action => 'index',:controller=>"roles"}</li>
            <li>#{link_if can_access('index','groups'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Groups', :action => 'index',:controller=>"groups"}</li>
          </ul>
          <br style="clear: left" />
        </div>
HTML


  end
if (controller == 'jobs'&& action== 'myjobs') || (controller=='jobs'&& action == 'actives') || (controller=='jobs'&& action == 'myteamjobs') || (controller=='jobs'&& action == 'history') || (controller=='jobs'&& action == 'index')
    html  = <<HTML
        <div class="jqueryslidetab" style="width:1024px;">
          <ul>
          <li>#{link_if can_access('myjobs','jobs'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;My Jobs', :action => 'myjobs',:controller=>"jobs"}</li>
          <li>#{link_if can_access('actives','jobs'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Active Jobs', :action => 'actives',:controller=>"jobs"}</li>
          <li>#{link_if can_access('myteamjobs','jobs'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;My Team Jobs', :action => 'myteamjobs',:controller=>"jobs"}</li>
          <li>#{link_if can_access('history','jobs'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;History jobs', :action => 'history',:controller=>"jobs"}</li>
          <li>#{link_if can_access('index','jobs'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;All jobs', :action => 'index',:controller=>"jobs"}</li>
          </ul>
          <br style="clear: left" />
        </div>
HTML


  end
  
if (controller == 'templates'&& action== 'index') || (controller=='template_mappings'&& action == 'index')
    html  = <<HTML
        <div class="jqueryslidetab" style="width:1024px;">
          <ul>
          <li>#{link_if can_access('index','templates'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Asia-Pacific Templates', :action => 'index' ,:controller=>"templates", :region=>'ap-southeast-1'}</li>
          <li>#{link_if can_access('index','template_mappings'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Announced Templates', :action => 'index' ,:controller=>"template_mappings"}</li>
          <li>#{link_if can_access('base_templates','templates'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Clean OS Templates', :action => 'base_templates' ,:controller=>"templates"}</li>
          </ul>
          <br style="clear: left" />
        </div>
HTML


  end
  
if (controller == 'clusters'&& action== 'actives') || (controller=='clusters'&& action == 'history') || (controller=='clusters'&& action == 'index')
    html  = <<HTML
        <div class="jqueryslidetab" style="width:1024px;">
          <ul>
          <li>#{ link_if can_access('actives','clusters'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Active Clusters', :action => 'actives',:controller=>"clusters"}</li>
              <li>#{link_if can_access('history','clusters'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;History Clusters', :action => 'history',:controller=>"clusters"}</li>
        <li>#{ link_if can_access('index','clusters'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Cluster Configurations', :action => 'index',:controller=>"clusters"}</li>
          </ul>
          <br style="clear: left" />
        </div>
HTML

  end
  
if (controller == 'securities'&& action== 'index') || (controller=='securitygroups'&& action == 'index')
    html  = <<HTML
        <div class="jqueryslidetab" style="width:1024px;">
          <ul>
          <li>#{link_if can_access('index','securities'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Security Port', :action => 'index' ,:controller=>"securities"}</li>
              <li>#{link_if can_access('index','securitygroups'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Securitygroups', :action => 'index',:controller=>"securitygroups"}</li>
          </ul>
          <br style="clear: left" />
        </div>
HTML

  end
  
if (controller == 'snapshots'&& action== 'index') || (controller=='ebsvolumes'&& action == 'index') 
    html  = <<HTML
        <div class="jqueryslidetab" style="width:1024px;">
          <ul>
          <li>#{link_if can_access('index','snapshots'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Snapshots', :action => 'index' ,:controller=>"snapshots"}</li>
              <li>#{link_if can_access('index','ebsvolumes'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;EBS Volumes', :action => 'index',:controller=>"ebsvolumes"}</li>
          </ul>
          <br style="clear: left" />
        </div>
HTML
  end
  
if (controller == 'demos'&& action== 'index') || (controller=='demo_products'&& action == 'index') || (controller=='demos'&& action == 'demo_job_list')
    html  = <<HTML
        <div class="jqueryslidetab" style="width:1024px;">
          <ul>
          <li>#{link_if can_access('index','demos'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Demos', :action => 'index' ,:controller=>"demos"}</li>
              <li>#{link_if can_access('index','demo_products'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Demo Products', :action => 'index',:controller=>"demo_products"}</li>
        <li>#{link_if can_access('demo_job_list','demos'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Demo Jobs', :action => 'demo_job_list',:controller=>"demos"}</li>
          </ul>
          <br style="clear: left" />
        </div>
HTML
  end

if (controller == 'softwares'&& action== 'index') || (controller=='license_requests'&& action == 'index')
    html  = <<HTML
        <div class="jqueryslidetab" style="width:1024px;">
          <ul>
          <li>#{link_if can_access('index','softwares'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Softwares', :action => 'index' ,:controller=>"softwares"}</li>
          <li>#{link_if can_access('index','license_requests'), '<img class="secondBarImage" src="/images/right.gif">&nbsp;Licenses Request', :action => 'index',:controller=>"license_requests"}</li>
          </ul>
          <br style="clear: left" />
        </div>
HTML
  end

 return html
end