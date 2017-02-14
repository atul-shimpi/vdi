class Template < ActiveRecord::Base
  #validates_uniqueness_of :name
  #validates_format_of :name, :with => /^[\d\w\s_]*$/i
  has_many :configurations
  has_many :jobs, :dependent => :destroy
  belongs_to :team, :class_name => "User", :foreign_key => "team_id"
  belongs_to :parentjob, :class_name => "Job", :foreign_key => "job_id"
  belongs_to :groups
  belongs_to :deleted_user, :class_name => "User" , :foreign_key => "deleted_by"
  belongs_to :creator, :class_name => "User" , :foreign_key => "creator_id"
  
  has_and_belongs_to_many :softwares,:class_name => "Software", :join_table => 'templates_softwares'
  
  def is_ebs
    if self.region != "iland"
      return (self.image_size != nil && self.image_size != "")
    else
      return true
    end
  end
  
  def is_virus_secure
    config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
    invalid_password = config["invalid_password"]
    return false if invalid_password.include?(self.password)
    return false if self.is_unsecure == 1
    return true  
  end
  
  def can_access(user)
    if !user.is_external || self.ispublic == 1
      return true
    end
    group_ids = Array.new
    groups = user.groups
    for group in groups
      group_ids<< group.id
    end
    if group_ids.include?(self.group_id)
      return true
    end
    return false
  end
  
  def self.createTemplate(cmd, template)
    begin
      str = IO.popen(cmd)
      i=0
      while line=str.gets  
        if i==0
          if line == nil
            return false
          end
          attrs = line.split(" ");
          j=0
          while j < attrs.length
            attr = attrs[j]
            if attr.include?("i386") or attr.include?("x86_64")
              template.architecture = attrs[j]
              template.image_type = attrs[j+1]
            end
            if attr.include?("available") || attr.include?("failed") || attr.include?("pending")
              template.state = attr
            end
            j = j + 1
          end
          template.image_size = ''
        end
        if i>0
          template.image_size = line.split(" ")[3]
        end
        config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
        keylist = config["keylist"].split(",")
        j = 0
        while j < keylist.length
          if line.downcase.include?keylist[j] 
            template.platform = config[keylist[j]]
            break
          end
          j = j + 1
        end
        if template.platform == '' or template.platform == nil
          template.platform = 'Other Linux'
        end
        i= i+1
      end
      template.save
      return true
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
      return false
    end
  end
  def get_parent
    if self.parentjob.nil?
      return nil
    else
      return self.parentjob.template
    end
  end
  def get_ancestors
    ancestor_list = Array.new
    ancestor = get_parent
    if ancestor
      ancestor_list << ancestor
    end
    while ancestor
      ancestor = ancestor.get_parent
      if ancestor
        ancestor_list.insert(0, ancestor)
      end
    end  
    return ancestor_list
  end
  def get_children
    sql = "select t.* from 
             templates t 
           left join jobs j
           on t.job_id = j.id
           left join templates t2 
           on j.template_id = t2.id
           where t2.id = #{self.id}"
    return Template.find_by_sql(sql)
  end
  def is_latest
    if self.template_mapping_id.nil? || self.template_mapping_id == 0
      return self.id
    end
    template_mapping = TemplateMapping.find(self.template_mapping_id)
    return template_mapping.template_id == self.id
  end
  
  #Return ture if template A contains a descendant belongs the team
  def has_team_template(team_id)
    result = false
    if self.team_id == team_id 
      result = true
    end
    self.get_children.each do |child|
      if child.has_team_template(team_id)
        result = true
      end
    end
    return result
  end   
end