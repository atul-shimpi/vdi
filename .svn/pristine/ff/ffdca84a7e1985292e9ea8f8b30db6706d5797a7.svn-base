class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.string :name
      t.string :description
      t.string :rpermission
      t.string :permission
      t.datetime :lease_time
      t.integer :user_id
      t.integer :template_id
      t.integer :ec2machine_id
      t.integer :group_id
      t.integer :instancetype_id
      t.integer :securitygroup_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
