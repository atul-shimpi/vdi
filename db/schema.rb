# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100709024555) do

  create_table "_tmp", :force => true do |t|
  end

  create_table "actions", :force => true do |t|
    t.string "action",      :limit => 45, :default => "", :null => false
    t.string "controller",  :limit => 45, :default => "", :null => false
    t.string "description",               :default => "", :null => false
  end

  create_table "actions_roles", :id => false, :force => true do |t|
    t.integer "role_id",   :default => 0, :null => false
    t.integer "action_id", :default => 0, :null => false
  end

  create_table "active_amis", :force => true do |t|
    t.string "ami_id",       :limit => 15
    t.string "imageState",   :limit => 15
    t.string "architecture", :limit => 15
    t.string "platform",     :limit => 15
    t.string "name"
    t.string "region",       :limit => 15
  end

  create_table "active_ilandmachines", :force => true do |t|
    t.string   "instance_id"
    t.string   "vapp_href"
    t.string   "public_dns"
    t.string   "private_dns"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "region",        :limit => 45
    t.string   "os",            :limit => 45
    t.string   "instance_type"
    t.string   "launch_time"
    t.string   "state"
    t.string   "public_ip"
    t.string   "private_ip"
  end

  create_table "active_ips", :force => true do |t|
    t.string "ip",          :limit => 45
    t.string "instance_id", :limit => 45
    t.string "scope",       :limit => 45
    t.string "alloc",       :limit => 45
    t.string "assoc",       :limit => 45
    t.string "region",      :limit => 45
  end

  create_table "active_machines", :force => true do |t|
    t.string   "instance_id",    :limit => 15
    t.string   "ami_id",         :limit => 15
    t.string   "public_dns"
    t.string   "private_dns"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "zone"
    t.string   "block_devices"
    t.string   "instance_type"
    t.string   "security_group"
    t.string   "key_pair"
    t.string   "launch_time"
    t.string   "state"
    t.string   "os",             :limit => 45
    t.string   "region",         :limit => 45
    t.string   "public_ip"
    t.string   "sg_id"
    t.string   "private_ip"
  end

  add_index "active_machines", ["security_group"], :name => "Index_2"

  create_table "active_snapshots", :force => true do |t|
    t.string   "snapshot_id", :limit => 15
    t.string   "ami",         :limit => 15
    t.string   "volume_id",   :limit => 15
    t.string   "status",      :limit => 15
    t.datetime "start_at"
    t.integer  "volumeSize"
    t.string   "region",      :limit => 15
    t.string   "description"
  end

  create_table "active_spots", :force => true do |t|
    t.string "spot_id",       :limit => 15
    t.string "os",            :limit => 15
    t.string "status",        :limit => 15
    t.string "instance_id",   :limit => 15
    t.string "region",        :limit => 15
    t.string "instance_type", :limit => 15
  end

  create_table "active_volumes", :force => true do |t|
    t.string   "volume_id",        :limit => 15
    t.integer  "size"
    t.string   "snapshot_id",      :limit => 15
    t.string   "instance_id",      :limit => 15
    t.string   "attach_device",    :limit => 45
    t.string   "availabilityZone", :limit => 45
    t.string   "status",           :limit => 15
    t.string   "region",           :limit => 15
    t.datetime "createTime"
    t.integer  "deleted",          :limit => 1,  :default => 0
  end

  create_table "cluster_params", :force => true do |t|
    t.string  "param_name",    :null => false
    t.integer "runcluster_id", :null => false
    t.text    "param_value"
  end

  create_table "clusterconfigurations", :force => true do |t|
    t.integer "cluster_id",                     :default => 0, :null => false
    t.integer "configuration_id",               :default => 0, :null => false
    t.string  "role",             :limit => 45
  end

  create_table "clusterlocks", :force => true do |t|
    t.integer "runcluster_id",               :default => 0, :null => false
    t.integer "job_id",                      :default => 0, :null => false
    t.integer "lock_id",                     :default => 0, :null => false
    t.string  "lock_status",   :limit => 45
  end

  create_table "clusters", :force => true do |t|
    t.string  "name",                      :default => "", :null => false
    t.string  "description"
    t.string  "state",       :limit => 45
    t.integer "user_id"
  end

  create_table "cmds", :force => true do |t|
    t.integer  "job_id",                    :default => 0,  :null => false
    t.text     "command",                                   :null => false
    t.string   "state",       :limit => 45, :default => "", :null => false
    t.string   "job_type",    :limit => 45, :default => "", :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "retry",                     :default => 0,  :null => false
    t.text     "error_log"
  end

  add_index "cmds", ["job_id"], :name => "job_id"

  create_table "configurations", :force => true do |t|
    t.string   "name"
    t.integer  "template_id"
    t.string   "template_name"
    t.string   "description"
    t.string   "rpermission"
    t.string   "permission"
    t.integer  "lease_time"
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "instancetype_id"
    t.integer  "securitygroup_id"
    t.string   "deploymentway"
    t.text     "commands",            :limit => 16777215
    t.text     "init_commands",       :limit => 2147483647
    t.string   "cmd_path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "poweroff_hour",                             :default => 0
    t.integer  "poweroff_min",                              :default => 0
    t.integer  "deleted",                                   :default => 0
    t.integer  "subnet_id"
    t.integer  "template_mapping_id"
    t.integer  "update_by"
  end

  add_index "configurations", ["name"], :name => "name"

  create_table "demo_jobs", :force => true do |t|
    t.integer  "job_id",     :default => 0,  :null => false
    t.integer  "demo_id",    :default => 0,  :null => false
    t.string   "name",       :default => "", :null => false
    t.string   "company",    :default => "", :null => false
    t.string   "email",      :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
  end

  create_table "demo_products", :force => true do |t|
    t.string "name",                              :default => "", :null => false
    t.string "contact_mail",                      :default => "", :null => false
    t.binary "logo",          :limit => 16777215
    t.text   "mail_template"
    t.string "auth_key",      :limit => 45
    t.string "sales_mail",                                        :null => false
    t.string "mail_subject",                      :default => "", :null => false
  end

  create_table "demos", :force => true do |t|
    t.string  "name",             :default => "", :null => false
    t.integer "demo_product_id"
    t.integer "configuration_id"
  end

  create_table "ebsvolumes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "job_id"
    t.string   "volume_id",        :limit => 15
    t.integer  "size"
    t.string   "snapshot_id",      :limit => 15
    t.string   "instance_id",      :limit => 15
    t.string   "attach_device",    :limit => 45
    t.string   "availabilityZone", :limit => 45
    t.string   "status",           :limit => 15
    t.string   "region",           :limit => 15
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "deleted",                        :default => 0
  end

  create_table "ec2machines", :force => true do |t|
    t.string   "instance_id",    :limit => 15
    t.string   "public_dns"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "private_dns"
    t.string   "zone",           :limit => 45
    t.string   "platform",       :limit => 45
    t.string   "virtualization", :limit => 45
    t.string   "block_devices"
    t.string   "lifecycle",      :limit => 45
    t.string   "security_group"
    t.string   "key_pair"
    t.datetime "launch_time"
    t.string   "status",         :limit => 45
    t.string   "public_ip"
    t.string   "sg_id"
    t.string   "private_ip"
  end

  add_index "ec2machines", ["instance_id"], :name => "instance_id"
  add_index "ec2machines", ["public_dns"], :name => "public_dns"
  add_index "ec2machines", ["public_ip"], :name => "public_ip"

  create_table "elasticips", :force => true do |t|
    t.integer  "job_id"
    t.string   "name",                        :default => "", :null => false
    t.string   "ip",                          :default => "", :null => false
    t.integer  "user_id",                     :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "region",        :limit => 45, :default => "", :null => false
    t.string   "instance_id"
    t.string   "scope"
    t.string   "allocation_id"
    t.string   "associate_id"
    t.integer  "deleted",                     :default => 0
  end

  create_table "emails", :force => true do |t|
    t.string   "subject"
    t.string   "from"
    t.string   "to"
    t.string   "bcc"
    t.text     "content"
    t.datetime "create_at"
    t.datetime "update_at"
    t.integer  "send_count",                    :default => 0
    t.integer  "send_successful",               :default => 0
    t.string   "status"
    t.string   "mailer",          :limit => 45
    t.string   "cc"
  end

  create_table "extend_lease_logs", :force => true do |t|
    t.integer  "job_id",         :null => false
    t.integer  "days"
    t.datetime "old_lease_time"
    t.datetime "new_lease_time"
    t.string   "reason"
    t.integer  "user_id"
    t.datetime "created_on"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "manager_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ispublic",    :default => 0
  end

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "user_id",  :default => 0, :null => false
    t.integer "group_id", :default => 0, :null => false
  end

  create_table "ilandmachines", :force => true do |t|
    t.string   "instance_id"
    t.string   "vapp_id"
    t.string   "public_dns"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "private_dns"
    t.string   "zone",           :limit => 45
    t.string   "platform",       :limit => 45
    t.string   "virtualization", :limit => 45
    t.string   "block_devices"
    t.string   "lifecycle",      :limit => 45
    t.string   "key_pair"
    t.datetime "launch_time"
    t.string   "status",         :limit => 45
    t.string   "public_ip"
    t.string   "sg_id"
    t.string   "private_ip"
  end

  add_index "ilandmachines", ["public_dns"], :name => "public_dns"

  create_table "instancestats", :force => true do |t|
    t.string   "zone",            :limit => 45, :null => false
    t.string   "os",              :limit => 45, :null => false
    t.integer  "instancetype_id",               :null => false
    t.integer  "count",                         :null => false
    t.datetime "created_at",                    :null => false
  end

  create_table "instancetypes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "architecture",     :limit => 20
    t.string   "description",                    :null => false
    t.float    "windows_price",                  :null => false
    t.float    "linux_price",                    :null => false
    t.float    "windows_maxprice",               :null => false
    t.float    "linux_maxprice",                 :null => false
    t.integer  "cpusize"
    t.integer  "memorysize"
    t.string   "dc",               :limit => 45
    t.integer  "seq"
  end

  create_table "jobs", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "rpermission"
    t.string   "permission"
    t.datetime "lease_time"
    t.integer  "user_id"
    t.integer  "template_id"
    t.string   "ami_name"
    t.integer  "ec2machine_id"
    t.integer  "group_id"
    t.integer  "instancetype_id"
    t.integer  "securitygroup_id"
    t.string   "securitytype_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.string   "request_id"
    t.string   "deploymentway",     :limit => 45
    t.float    "max_price"
    t.integer  "poweroff_hour",                         :default => 0
    t.integer  "poweroff_min",                          :default => 0
    t.integer  "configuration_id"
    t.string   "telnet_service",    :limit => 45,       :default => "disabled"
    t.float    "cost",                                  :default => 0.0
    t.integer  "runcluster_id"
    t.string   "role"
    t.string   "usage",             :limit => 45
    t.integer  "project_id"
    t.integer  "subnet_id"
    t.string   "machinepassword"
    t.integer  "support_id"
    t.text     "init_commands",     :limit => 16777215
    t.integer  "ilandmachine_id"
    t.integer  "is_busy",           :limit => 1,        :default => 0
    t.string   "region",            :limit => 45
    t.integer  "locked",            :limit => 1,        :default => 0
    t.integer  "is_inactive",                           :default => 0
    t.datetime "inactive_since"
  end

  add_index "jobs", ["configuration_id"], :name => "configuration_id"
  add_index "jobs", ["created_at"], :name => "created_atIndex"
  add_index "jobs", ["ec2machine_id"], :name => "ec2machine_id"
  add_index "jobs", ["is_busy"], :name => "is\037_busy"
  add_index "jobs", ["lease_time"], :name => "leasetimeindex"
  add_index "jobs", ["machinepassword"], :name => "password"
  add_index "jobs", ["request_id"], :name => "request_id"
  add_index "jobs", ["runcluster_id"], :name => "runcluster_id"
  add_index "jobs", ["securitytype_name"], :name => "Index_3"
  add_index "jobs", ["state"], :name => "state"
  add_index "jobs", ["user_id"], :name => "user_id"

  create_table "jobs_view_1", :force => true do |t|
    t.string "owner"
    t.string "email"
    t.string "dns"
    t.string "state"
  end

  create_table "license_requests", :force => true do |t|
    t.integer "request_id"
    t.integer "approval_id"
    t.integer "software_id"
    t.integer "count"
    t.string  "status"
    t.integer "last_edit_by"
  end

  create_table "locks", :force => true do |t|
    t.string  "name",       :default => "", :null => false
    t.integer "cluster_id", :default => 0,  :null => false
  end

  create_table "newcommands", :force => true do |t|
    t.integer "configuration_id", :default => 0,  :null => false
    t.string  "commands",         :default => "", :null => false
    t.string  "description"
    t.string  "cmd_path"
  end

  create_table "roles", :force => true do |t|
    t.string  "role_name"
    t.string  "description"
    t.integer "parent_role", :default => 0, :null => false
    t.text    "permissions"
    t.integer "POSITION"
  end

  add_index "roles", ["parent_role"], :name => "rm_roles_parent_role_index"
  add_index "roles", ["role_name"], :name => "role_name_index"

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "user_id", :default => 0, :null => false
    t.integer "role_id", :default => 0, :null => false
  end

  add_index "roles_users", ["role_id"], :name => "role_id_index"
  add_index "roles_users", ["user_id"], :name => "user_id_index"

  create_table "runclusters", :force => true do |t|
    t.string  "name",                      :default => "", :null => false
    t.string  "description"
    t.integer "cluster_id",                :default => 0,  :null => false
    t.string  "state",       :limit => 45
    t.integer "user_id"
  end

  create_table "runcommands", :force => true do |t|
    t.integer  "job_id",                          :default => 0, :null => false
    t.text     "commands",    :limit => 16777215,                :null => false
    t.string   "description"
    t.string   "cmd_path"
    t.string   "state",       :limit => 45
    t.string   "cmd_type",    :limit => 45
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "ret_mark",    :limit => 16777215
  end

  add_index "runcommands", ["job_id"], :name => "job_id"

  create_table "securities", :force => true do |t|
    t.string  "name"
    t.string  "protocol"
    t.integer "port_from"
    t.string  "source"
    t.integer "port_to"
  end

  create_table "securities_securitygroups", :id => false, :force => true do |t|
    t.integer "securitygroup_id", :default => 0, :null => false
    t.integer "security_id",      :default => 0, :null => false
  end

  create_table "securitygroups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "securitygroups", ["name"], :name => "name"

  create_table "securitygroups_backup", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "securitygroups_backup", ["name"], :name => "name"

  create_table "securitytypes", :force => true do |t|
    t.string "name"
    t.string "state"
    t.string "region",           :limit => 45, :default => "us-east-1", :null => false
    t.string "securitygroup_id"
  end

  add_index "securitytypes", ["name"], :name => "name"
  add_index "securitytypes", ["securitygroup_id"], :name => "sg_id"

  create_table "sensitivemasks", :force => true do |t|
    t.string "name",             :limit => 45
    t.string "sensitive_string"
    t.string "mask_string"
  end

  create_table "snapshots", :force => true do |t|
    t.integer  "user_id"
    t.string   "snapshot_id", :limit => 15
    t.integer  "size"
    t.integer  "job_id"
    t.string   "volume_id",   :limit => 15
    t.string   "status",      :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "region",      :limit => 15
    t.string   "name"
    t.integer  "deleted",                   :default => 0
  end

  create_table "softwares", :force => true do |t|
    t.string  "name"
    t.string  "version"
    t.integer "license_count"
    t.string  "download_link"
    t.string  "license_detail"
    t.boolean "is_free"
    t.string  "download_account"
    t.string  "password"
    t.boolean "open_for_request"
  end

  create_table "spot_quotas", :force => true do |t|
    t.string  "instance_type", :limit => 45, :default => "", :null => false
    t.string  "region",        :limit => 45, :default => "", :null => false
    t.string  "os",            :limit => 45, :default => "", :null => false
    t.integer "quota",                       :default => 0
  end

  create_table "subnets", :force => true do |t|
    t.string  "subnet_id",               :default => "", :null => false
    t.string  "vpc_id",                  :default => "", :null => false
    t.string  "region",    :limit => 45, :default => "", :null => false
    t.integer "deleted",                 :default => 0
    t.string  "name",                    :default => "", :null => false
  end

  create_table "template_mappings", :force => true do |t|
    t.string   "name",                      :default => "",      :null => false
    t.integer  "template_id",               :default => 0,       :null => false
    t.integer  "version",                   :default => 1,       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "usage",       :limit => 45, :default => "other", :null => false
    t.integer  "update_by"
    t.integer  "is_deleted",                :default => 0
  end

  create_table "templates", :force => true do |t|
    t.string   "name"
    t.string   "ec2_ami"
    t.string   "user"
    t.string   "password"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "architecture",        :limit => 55
    t.string   "platform",            :limit => 100
    t.string   "image_type",          :limit => 55
    t.string   "image_size",          :limit => 55
    t.integer  "dev_pay",                            :default => 0
    t.integer  "deleted",                            :default => 0
    t.integer  "job_id",                             :default => 0
    t.integer  "team_id"
    t.string   "state",               :limit => 45
    t.integer  "telnet_enabled",                     :default => 0
    t.string   "region",              :limit => 45,  :default => "us-east-1", :null => false
    t.integer  "ispublic",                           :default => 0
    t.integer  "group_id",                           :default => 0
    t.integer  "template_mapping_id"
    t.integer  "deleted_by"
    t.integer  "is_cluster_instance",                :default => 0,           :null => false
    t.integer  "creator_id",                                                  :null => false
    t.integer  "allow_large",         :limit => 1,   :default => 0
    t.string   "export_path"
    t.boolean  "base_template",                      :default => false
    t.integer  "is_unsecure",                        :default => 0
  end

  add_index "templates", ["ec2_ami"], :name => "Index"
  add_index "templates", ["password"], :name => "password"
  add_index "templates", ["team_id"], :name => "team_id"

  create_table "templates_exported", :force => true do |t|
    t.string "size", :limit => 10,  :null => false
    t.string "path", :limit => 100, :null => false
  end

  create_table "templates_softwares", :id => false, :force => true do |t|
    t.integer "template_id", :null => false
    t.integer "software_id", :null => false
  end

  create_table "tempmember_roles", :force => true do |t|
    t.integer "member_id",      :null => false
    t.integer "role_id",        :null => false
    t.integer "inherited_from"
  end

  add_index "tempmember_roles", ["member_id"], :name => "index_member_roles_on_member_id"
  add_index "tempmember_roles", ["role_id"], :name => "index_member_roles_on_role_id"

  create_table "tempmembers", :force => true do |t|
    t.integer  "user_id",                :default => 0,     :null => false
    t.integer  "project_id",             :default => 0,     :null => false
    t.datetime "created_on"
    t.boolean  "mail_notification",      :default => false, :null => false
    t.boolean  "dmsf_mail_notification"
  end

  add_index "tempmembers", ["project_id"], :name => "index_members_on_project_id"
  add_index "tempmembers", ["user_id", "project_id"], :name => "index_members_on_user_id_and_project_id", :unique => true
  add_index "tempmembers", ["user_id"], :name => "index_members_on_user_id"

  create_table "temproles", :force => true do |t|
    t.string  "name",               :limit => 30, :default => "",    :null => false
    t.integer "position",                         :default => 1
    t.boolean "assignable",                       :default => true
    t.integer "builtin",                          :default => 0,     :null => false
    t.text    "permissions"
    t.boolean "hidden_on_overview",               :default => false
  end

  create_table "temproles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "tempusers", :force => true do |t|
    t.string   "login",                           :default => "",    :null => false
    t.string   "jira_user_account",               :default => ""
    t.string   "skype_id",          :limit => 45
    t.string   "hashed_password",   :limit => 40, :default => "",    :null => false
    t.string   "firstname",                       :default => "",    :null => false
    t.string   "lastname",          :limit => 30, :default => "",    :null => false
    t.string   "mail",                            :default => ""
    t.boolean  "admin",                           :default => false, :null => false
    t.integer  "status",                          :default => 1,     :null => false
    t.datetime "last_login_on"
    t.string   "language",          :limit => 5,  :default => "en"
    t.integer  "auth_source_id"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.string   "type"
    t.string   "identity_url"
    t.string   "mail_notification",               :default => "",    :null => false
    t.string   "svn_account"
    t.string   "authsubtoken"
    t.boolean  "np"
  end

  add_index "tempusers", ["auth_source_id"], :name => "index_users_on_auth_source_id"
  add_index "tempusers", ["id", "type"], :name => "index_users_on_id_and_type"

  create_table "users", :force => true do |t|
    t.string   "account"
    t.string   "password"
    t.string   "name"
    t.string   "email"
    t.string   "location"
    t.integer  "group_id"
    t.boolean  "disabled",                               :default => false
    t.integer  "tam_specialization_id"
    t.datetime "last_login_on"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.integer  "has_access_to_all_groups", :limit => 1,  :default => 0,     :null => false
    t.string   "jira_user_account"
    t.string   "jira_user_id",             :limit => 45
    t.string   "codesion_id",              :limit => 45
    t.string   "skype_id",                 :limit => 45
  end

  add_index "users", ["account"], :name => "account_index"
  add_index "users", ["group_id"], :name => "group_id"

end
