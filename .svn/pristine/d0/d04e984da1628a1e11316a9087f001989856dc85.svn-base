module TemplatesHelper
  def can_manage_template(user, template)
    if user.is_external
      if template.creator_id == user.id
        return true       
      else 
        return false
      end
    else
      return true 
    end    
  end
end
