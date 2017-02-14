class CreateTemplates < ActiveRecord::Migration
  def self.up
    create_table :templates do |t|
      t.string :name
      t.string :ec2_ami
      t.string :user
      t.string :password
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :templates
  end
end
