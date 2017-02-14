ActionController::Routing::Routes.draw do |map|
  map.connect 'templates/index', :controller => 'templates', :action => 'index', :method => :post
  map.connect 'templates/capturetemplate', :controller => 'templates', :action => 'capturetemplate', :method => :post
  map.connect 'templates/template_trace', :controller => 'templates', :action => 'template_trace', :method => :post 
  map.connect 'templates/base_templates', :controller => 'templates', :action => 'base_templates', :method => :post 
  map.connect 'templates/newiland', :controller => 'templates', :action => 'newiland', :method => :post  
  map.connect 'configurations/news', :controller => 'configurations', :action => 'news', :method => :post
  map.connect 'configurations/deploy_vdi_build', :controller => 'configurations', :action => 'deploy_vdi_build', :method => :post
  map.connect 'configurations/undeploy_vdi_build', :controller => 'configurations', :action => 'undeploy_vdi_build', :method => :post
  map.connect 'configurations/webservicePoweroffjob', :controller => 'configurations', :action => 'webservicePoweroffjob', :method => :post  
  map.connect 'jobs/getActiveVDIJobs', :controller => 'jobs', :action => 'getActiveVDIJobs', :method => :post 
  map.connect 'jobs/actives', :controller => 'jobs', :action => 'actives', :method => :post 
  map.connect 'jobs/history', :controller => 'jobs', :action => 'history', :method => :post 
  map.connect 'jobs/supported', :controller => 'jobs', :action => 'supported', :method => :post   
  map.connect 'jobs/myjobs', :controller => 'jobs', :action => 'myjobs', :method => :post 
  map.connect 'jobs/myteamjobs', :controller => 'jobs', :action => 'myteamjobs', :method => :post 
  map.connect 'jobs/templatejobs', :controller => 'jobs', :action => 'templatejobs', :method => :post 
  map.connect 'jobs/generate_rdp', :controller => 'jobs', :action => 'generate_rdp', :method => :post 
  map.connect 'jobs/initialcommand', :controller => 'jobs', :action => 'initialcommand', :method => :post
  map.connect 'jobs/undeployJobByInstanceID', :controller => 'jobs', :action => 'undeployJobByInstanceID', :method => :post 
  map.connect 'jobs/update_password', :controller => 'jobs', :action => 'update_password', :method => :post 
  map.connect 'jobs/get_job_info', :controller => 'jobs', :action => 'get_job_info', :method => :post 
  map.connect 'clusters/actives', :controller => 'clusters', :action => 'actives', :method => :post
  map.connect 'clusters/history', :controller => 'clusters', :action => 'history', :method => :post
  map.connect 'clusters/webserviceDeploycluster', :controller => 'clusters', :action => 'webserviceDeploycluster', :method => :post
  map.connect 'clusters/webserviceUndeploycluster', :controller => 'clusters', :action => 'webserviceUndeploycluster', :method => :post
  map.connect 'clusters/checklock', :controller => 'clusters', :action => 'checklock', :method => :post
  map.connect 'clusters/updatelock', :controller => 'clusters', :action => 'updatelock', :method => :post
  map.connect 'clusters/rolemapping', :controller => 'clusters', :action => 'rolemapping', :method => :post
  map.connect 'clusters/set_param', :controller => 'clusters', :action => 'set_param', :method => :post
  map.connect 'clusters/get_param', :controller => 'clusters', :action => 'get_param', :method => :post
  map.connect 'jobs/import', :controller => 'jobs', :action => 'import', :method => :post  
  map.connect 'jobs/byuser', :controller => 'jobs', :action => 'byuser', :method => :post  
  map.connect 'jobs/unsecure_jobs', :controller => 'jobs', :action => 'unsecure_jobs', :method => :post  
  map.connect 'reports/active_jobs_by_user', :controller => 'reports', :action => 'active_jobs_by_user', :method => :post 
  map.connect 'reports/index', :controller => 'reports', :action => 'index', :method => :post
  map.connect 'reports/cost_by_user', :controller => 'reports', :action => 'cost_by_user', :method => :post   
  map.connect 'reports/cost_by_team', :controller => 'reports', :action => 'cost_by_team', :method => :post   
  map.connect 'reports/cost_by_template', :controller => 'reports', :action => 'cost_by_template', :method => :post   
  map.connect 'template_mappings/show/:id' , :controller => 'template_mappings', :action => 'show', :method => :post
  map.connect 'template_mappings/edit/:id' , :controller => 'template_mappings', :action => 'edit', :method => :post
  map.connect 'template_mappings/delete/:id' , :controller => 'template_mappings', :action => 'destroy', :method => :post
#  map.connect 'templates', :controller => 'templates', :action => 'index', :method => :post
#  map.connect 'templates/create', :controller => 'templates', :action => 'create', :method => :post  
  map.connect 'ebsvolumes/attach' , :controller => 'ebsvolumes', :action => 'attach', :method => :post
  map.connect 'ebsvolumes/detach' , :controller => 'ebsvolumes', :action => 'detach', :method => :post 
  map.connect 'demo_products/product_logo', :controller => 'demo_products', :action => 'product_logo', :method => :post
  map.connect 'demos/demodeploy', :controller => 'demos', :action => 'demodeploy', :method => :post
  map.connect 'demos/demo_job_deployed', :controller => 'demos', :action => 'demo_job_deployed', :method => :post    
  map.connect 'demos/demo_job_list', :controller => 'demos', :action => 'demo_job_list', :method => :post
  map.resources :securities

  map.resources :instancetypes

  map.resources :securitygroups

  map.resources :ec2machines

  map.resources :softwares

  map.resources :license_requests

  map.resources :templates
  
  map.resources :template_mappings

  map.resources :jobs

  map.resources :groups, :collections =>{:update_group_table=>:get}

  map.resources :actions

  map.resources :roles
  map.resources :elasticips
  
  map.resources :newcommands
  
  map.resources :runcommands
  
  map.resources :configurations
  
  map.resources :clusters
  
  map.resources :runclusters
  map.resources :ebsvolumes
  map.resources :snapshots
  map.resources :demos
  map.resources :demo_products 
  map.resources :sensitivemasks
  map.resources :extend_lease_logs
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
   map.root :controller => "users", :action => "login"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
