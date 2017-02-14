class TemplateMapping < ActiveRecord::Base
  belongs_to :template
  belongs_to :updater,:class_name => 'User', :foreign_key => :update_by
  validates_presence_of :name, :template_id
  
  def self.create_instance(params)
    template_mapping = TemplateMapping.new(params[:template_mapping])
    template_mapping.created_at = Time.now
    is_success = template_mapping.save
    mapped_template = Template.find(params[:template_mapping][:template_id])
    mapped_template.template_mapping_id = template_mapping.id
    if is_success and mapped_template.save
      return template_mapping
    end
  end
  
  def update_instance(params)
    self.update_attributes(params[:template_mapping])
    self.version += 1
    self.updated_at = Time.now
    is_success = self.save
    mapped_template = Template.find(params[:template_mapping][:template_id])
    mapped_template.template_mapping_id = self.id
    is_success and mapped_template.save
  end
  
  def history_templates
    Template.find(:all, :conditions => ["template_mapping_id = '#{self.id}'"])
  end
  
  def self.template_mappings_by_team_and_usage (usage, team_id, architecture)
    return TemplateMapping.find_by_sql("select tm.id from template_mappings tm 
                       left join templates t
                       on tm.template_id = t.id
                       where tm.usage = '#{usage}'
                         and t.team_id = #{team_id}
                         and t.architecture = '#{architecture}'")
  end
  
end