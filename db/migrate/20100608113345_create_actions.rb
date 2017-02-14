class CreateActions < ActiveRecord::Migration
  def self.up
    create_table :actions do |t|
      t.string "action",      :limit => 45, :default => "", :null => false
      t.string "controller",  :limit => 45, :default => "", :null => false
      t.string "description",               :default => "", :null => false
    end
  end

  def self.down
    drop_table :actions
  end
end
