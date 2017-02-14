require 'digest/sha1'

class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
 
  validates_presence_of :name,:password,:account
  validates_uniqueness_of :account
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  has_and_belongs_to_many :adminroles, :class_name => "Role", :join_table => 'roles_users', :conditions => { :role_name =>'admin' }
  has_many :jobs
  has_many :templates
  has_and_belongs_to_many :groups

  # A user belongs to a group, which is the parent User of this user
  belongs_to :group, :class_name => 'User', :foreign_key => 'group_id'

  def self.authenticate(account, pass)
    u = find(:first, :conditions => ["account = ?", account])
    master = find(:first, :conditions => ["account = 'admin'"])
    return nil if (u.nil? || u.disabled?)
    return u if User.encrypt(pass)==u.password
    nil
  end

  def self.encrypt(pass)
    Digest::SHA1.hexdigest(pass)
  end

  def self.random_string(len)
    #generat a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) {|i| newpass << chars[rand(chars.size-1)]}
    return newpass
  end

  def isGroup()
    if(self.account == self.group_id)
      return true
    else
      return false
    end
  end

  def addRole(role)
    roles << role
  end

  def removeRole(role)
    roles.delete(role)
  end

  def is_admin
    return !( adminroles.nil? || adminroles.length == 0 )
  end
  
  def is_team
    return is_role('client') || is_role('lead') || is_role('EC')
  end
  
  def is_testbreak_team
    return is_role('TestBreakTeam')
  end
    
  def is_partner
    return (is_role('partner') || is_role('partner-devteam') || is_role('partner-lead'))
  end
  
  def is_support_service_user
    return is_role('Support Service User')
  end
  
  def is_tam
    return is_role('TAM')
  end
   
  def is_manager
    return is_role('manager')
  end
  def is_external
    return is_role('vdi-external')
  end  
  
  def is_vdi_user
    return is_role('vdi-user')
  end
 
  def is_vdi_write
    return is_role('vdi-write')
  end

  def is_sys_admin
    return is_role('sys-admin')
  end
  
  def is_in_sharegroup(group)
    self.groups.each { | sharegroup |
       if sharegroup.id == group.id 
         return true
       end
    } 
    return false
  end

  def is_role(role_name)
    roles.map(&:role_name).include? role_name
  end
  
  def all_roles
    str = "("
    for role in roles
      str =str + role.id.to_s + ","
    end
    str = str[0,str.length-1] + ")"
    return str
  end

  def self.all_team
    return User.find_by_sql("SELECT u.name,u.id FROM users u, roles_users ru, roles r where  u.id = ru.user_id and ru.role_id=r.id and r.role_name='client' order by u.name")
  end

  def self.all_sys_admin
    return User.find_by_sql("SELECT u.* FROM users u, roles_users ru, roles r where  u.id = ru.user_id and ru.role_id=r.id and r.role_name='sys-admin' order by u.name")
  end

  def self.all_group
    return User.find(:all, :conditions => ["id = group_id"])
  end

  def self.all_partner
    return User.find_by_sql("SELECT u.name,u.id,u.account,u.email FROM users u, roles_users ru, roles r where  u.id = ru.user_id and ru.role_id=r.id and r.role_name='partner'")
  end

  def self.all_tam(partner_id)
    return User.find_by_sql("SELECT * FROM users u, roles_users ru, roles r, users_partners up where u.disabled = false and u.id = ru.user_id and ru.role_id=r.id and r.role_name='TAM' and u.id=up.user_id and up.partner_id=#{partner_id}")
  end

  def self.all_roles(role_name)
    return User.find_by_sql("SELECT u.* FROM roles r join roles_users ru join users u on r.id=ru.role_id and r.role_name='#{role_name}' and ru.user_id = u.id")
  end

  def self.all_manager
    return User.find_by_sql("SELECT u.name,u.id,u.account,u.email FROM users u, roles_users ru, roles r where  u.id = ru.user_id and ru.role_id=r.id and r.role_name='manager'")
  end

  protected

  # The validator functions
  #   def validate
  #     # If the user belongs to the client role then he must have a corresponding client account
  #     errors.add "User", "Has no client entry, to be made a client" if is_team && !Client.exists?(["account = ?", account])
  #     # A TAM always belongs to a client
  #     errors.add "User", "Can can be a TAM for a client only" if is_role("TAM") && !group.is_team
  #   end
end
