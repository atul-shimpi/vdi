class CreateTableRolesUsers < ActiveRecord::Migration
  def self.up
  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "user_id", :default => 0, :null => false
    t.integer "role_id", :default => 0, :null => false
  end
  end

  def self.down
    drop_table :roles_users
  end
end
