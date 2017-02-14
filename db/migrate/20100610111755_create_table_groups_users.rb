class CreateTableGroupsUsers < ActiveRecord::Migration
  def self.up
      create_table "groups_users", :id => false, :force => true do |t|
    t.integer "user_id",   :default => 0, :null => false
    t.integer "group_id", :default => 0, :null => false
  end
  end

  def self.down
     drop_table :groups_users
  end
end
