class DemosController < ApplicationController
  layout "application",:except=>[:demodeploy, :demo_job_deployed]
  # GET /demos
  # GET /demos.xml
  def index
    @demos = Demo.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @demos }
    end
  end

  # GET /demos/1
  # GET /demos/1.xml
  def show
    @demo = Demo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @demo }
    end
  end

  # GET /demos/new
  # GET /demos/new.xml
  def new
    @demo = Demo.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @demo }
    end
  end

  # GET /demos/1/edit
  def edit
    @demo = Demo.find(params[:id])
  end

  # POST /demos
  # POST /demos.xml
  def create
    @demo = Demo.new(params[:demo])
    
    respond_to do |format|
      if @demo.save
        flash[:notice] = 'Demo was successfully created.'
        format.html { redirect_to(@demo) }
        format.xml  { render :xml => @demo, :status => :created, :location => @demo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @demo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /demos/1
  # PUT /demos/1.xml
  def update
    @demo = Demo.find(params[:id])

    respond_to do |format|
      if @demo.update_attributes(params[:demo])
        flash[:notice] = 'Demo was successfully updated.'
        format.html { redirect_to(@demo) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @demo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /demos/1
  # DELETE /demos/1.xml
  def destroy
    @demo = Demo.find(params[:id])
    @demo.destroy

    respond_to do |format|
      format.html { redirect_to(demos_url) }
      format.xml  { head :ok }
    end
  end
  
  def demodeploy
    product = params[:product]
    @demo_product = DemoProduct.find(:first, :conditions=>("name='#{product}'"))
  end
  
  def creat_demo_job
    product = params[:product]
    demo_product = DemoProduct.find(:first, :conditions=>("name='#{product}'"))
    if demo_product.nil?
      flash[:notice] = 'Your demo deploy link is not correct, please contact the product team'
      redirect_to :action=> "demodeploy"
      return
    end
    
    auth_key=params[:auth_key]
    if auth_key != demo_product.auth_key
      flash[:notice] = 'Authentication Key Was not correct, please contact product team for the corrcet key'
      redirect_to :action=> "demodeploy", :product=> product
      return
    end
    name = params[:name]
    company = params[:company]
    email = params[:email]
    
    if name.blank? || company.blank? || email.blank? || !email.include?('@')
      flash[:notice] = 'You input info was not correct'
      redirect_to :action=> "demodeploy", :product=> product     
      return
    end
    
    demo_id = params[:demo_id]
    demo = Demo.find(:last, :conditions => "id= #{demo_id}")
    
    demo_job = DemoJob.new
    demo_job.name = name
    demo_job.company = company
    demo_job.email = email
    
    configuration = demo.configuration
    demo_job.demo_id = demo.id
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    user_id = config["demo_deploy_userid"]
    user = User.find(user_id)
    
    job = Job.new
    Job.deployjobfromconf(job,configuration,user)
    Configuration.add_userdata_as_commands(job,configuration)
    Configuration.generate_telnet_commands(job,configuration) 
    #TODO: Need make the demo lease configurable by product
    job.lease_time = Time.now + 30*24*60*60
    job.deploymentway = 'normal'
    job.usage = 'Demo'
    job.save
    
    demo_job.job_id = job.id
    demo_job.state = job.state
    demo_job.save
    redirect_to :action=> "demo_job_deployed", :product=> product     
    return       
  end
  def demo_job_deployed
    product = params[:product]
    @demo_product = DemoProduct.find(:first, :conditions=>("name='#{product}'"))      
  end
  def demo_job_list
    scope = params[:scope]
    if scope.blank? || scope != 'all'
      @demo_jobs = DemoJob.find(:all, :conditions=>("state in ('Run', 'Pending')"))
    else
      @demo_jobs = DemoJob.find(:all)
    end
  end
end