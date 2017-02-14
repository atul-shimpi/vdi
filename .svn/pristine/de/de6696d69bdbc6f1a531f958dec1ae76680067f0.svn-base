class CreateTableactionsRoles < ActiveRecord::Migration
  def self.up
  create_table "actions_roles", :id => false, :force => true do |t|
    t.integer "role_id",   :default => 0, :null => false
    t.integer "action_id", :default => 0, :null => false
  end
  end

  def self.down
    drop_table :actions_roles
  end
end
