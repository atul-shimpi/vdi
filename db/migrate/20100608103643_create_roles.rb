class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string  "role_name"
      t.string  "description"
      t.integer "parent_role", :default => 0, :null => false
    end
  end

  def self.down
    drop_table :roles
  end
end
