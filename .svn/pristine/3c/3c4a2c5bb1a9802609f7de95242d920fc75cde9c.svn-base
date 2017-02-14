class CreateEc2machines < ActiveRecord::Migration
  def self.up
    create_table :ec2machines do |t|
      t.integer :instance_id
      t.string :public_dns

      t.timestamps
    end
  end

  def self.down
    drop_table :ec2machines
  end
end
