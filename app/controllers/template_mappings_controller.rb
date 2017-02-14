class TemplateMappingsController < ApplicationController
  before_filter :get_templates, :only => [:new, :edit]
  
  def index
    filter = XFilter.new
    filter.equal 0,"template_mappings.is_deleted"
    template_name = params[:template_name]
    template_mapping_name = params[:template_mapping_name]
    search_filter = params[:filter]
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    per_page = config["per_page"]
    if !params[:template_id].blank?
      filter.equal params[:template_id], "template_id"      
    else
      if template_name != nil && template_name.strip != ""
        filter.like template_name.strip, "templates.name"
      end
      if template_mapping_name != nil && template_mapping_name.strip != ""
        filter.like template_mapping_name.strip, "template_mappings.name"
      end
    
      if search_filter && search_filter[:team_id]     
        team_id = search_filter[:team_id]
        if team_id !=nil && team_id.strip != "" 
          filter.equal team_id, "templates.team_id"
        end
      end

      if search_filter && search_filter[:usage]     
        usage = search_filter[:usage]
        if usage !=nil && usage.strip != "" 
          filter.equal usage, "template_mappings.usage"
        end
      end
    end
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    @template_usages = config["template_usage"].split(",")
  
    @template_mappings = TemplateMapping.find(:all, :include => [:template] ,:conditions => filter.conditions, :order=> "template_mappings.id DESC")
    @template_mappings = @template_mappings.paginate  :page => params[:page],:per_page => per_page
  end
  
  def history_templates
    id = params[:id]
    @show_template_mapping = find_template_mapping_by_id_and_render_if_nil(id)
    @show_history_templats = @show_template_mapping.history_templates
  end
  
  def show
    id = params[:id]
    @show_template_mapping = find_template_mapping_by_id_and_render_if_nil(id)
    return if @show_template_mapping.nil?
    @show_template = @show_template_mapping.template
  end
  
  def new
    @template_mapping = TemplateMapping.new
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    @template_usages = config["template_usage"].split(",")    
  end
  
  def create
    mapped_template = Template.find(params[:template_mapping][:template_id])
    if params[:template_mapping][:usage] == "Dev" && !current_user.is_admin
      tids = TemplateMapping.template_mappings_by_team_and_usage("Dev", mapped_template.team_id, mapped_template.architecture) 
      if tids && tids.size > 0
        flash[:notice] = "ERROR: Only 1 Dev template mapping is allowed for a product in the same architecture. Currently following similar template mapping exists: " + tids[0][:id].to_s
        redirect_to :action => :index
        return
      end
    end    
    is_success = TemplateMapping.create_instance(params)
    create_flash_notice(params[:template_mapping][:name], "create", is_success)
    
    redirect_to :action => :index
  end
  
  def edit
    id = params[:id]
    @edit_template_mapping = find_template_mapping_by_id_and_render_if_nil(id)
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    @template_usages = config["template_usage"].split(",")    
    return if @edit_template_mapping.nil?
  end
  
  def update
    id = params[:id]
    template_mapping = find_template_mapping_by_id_and_render_if_nil(id)
    return if template_mapping.nil?
    if params[:template_mapping][:usage] == "Dev" && !current_user.is_admin
      tids = TemplateMapping.template_mappings_by_team_and_usage("Dev", template_mapping.template.team_id, template_mapping.template.architecture) 
      if tids && tids.size > 0
        flash[:notice] = "ERROR: Only 1 Dev template mapping is allowed for a product in the same architecture. Currently following similar template mapping exists: " + tids[0][:id].to_s
        redirect_to :action => :index
        return
      end
    end
    template_mapping.update_by = current_user.id
    is_success = template_mapping.update_instance(params)
    create_flash_notice(template_mapping.name, "edit", is_success)
    redirect_to :action => :index  
  end

  def destroy
    id = params[:id]
    template_mapping = find_template_mapping_by_id_and_render_if_nil(id)
    return if template_mapping.nil?
    template_mapping.is_deleted = 1
    result = template_mapping.save
    create_flash_notice(template_mapping.name, "delete", result)
    redirect_to :action => :index  
  end
  
  def get_templates
    @templates = Template.find(:all, :conditions=> ["deleted = 0"])
  end
  
  private
  def find_template_mapping_by_id_and_render_if_nil(id)
    template_mapping = TemplateMapping.find_by_id id unless id.blank?
    if template_mapping.nil?
      flash[:notice] = "Can not find template mapping with '#{id}' id in VDI."
      redirect_to :action => "index"
      return nil
    end
    return template_mapping
  end
  
  private
  def create_flash_notice(template_mapping_name, action, is_success)
    if is_success
      flash[:notice] = "#{action.capitalize} template mapping #{template_mapping_name} successful."
    else
      flash[:notice] = "#{action.capitalize} template mapping #{template_mapping_name} failure. Please ensure fill in name and template"
      flash[:notice] = "#{action.capitalize} template mapping #{template_mapping_name} failure." if action == 'delete'
    end
  end
  
end