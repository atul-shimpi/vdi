class ReportsController < ApplicationController
  def index
    
  end
  
  def active_jobs_by_user
    @reports = Job.find_by_sql("select u.id as userid,
                               u.name as name, 
                               sum(case when j.state in ('Run', 'Capturing') then 1 else 0 end) as running, 
                               sum(case when j.state in ('PowerOff') then 1 else 0 end) as poweroff,
                               count(*) as alljobs
                               from jobs j                               
                               left join users u
                               on u.id = j.user_id
                               group by u.id
                               order by running desc")
  end
  
  def all_jobs_by_owner_disabled
    sql = "select
          u.account,
          u.email,
          j.id as job_id, 
          j.name as job_name,
          j.state as job_state,
          j.lease_time,
          j.cost as job_cost,
          e.public_dns as public_dns 
      from
           (select * from jobs where state in ('Run', 'Pending', 'Open', 'Deploying', 'PowerOFF', 'Capturing')) as j
           left join users u  
           on u.id = j.user_id
           left join ec2machines e
           on j.ec2machine_id = e.id  
      where u.disabled = 1  
    "
    @reports = User.find_by_sql(sql)
  end
  
  def cost_by_user
    @orderby = params[:orderby]
    if @orderby == nil || @orderby.strip == ""
      @orderby = 'per_unit'
    end
    
    @scope = params[:scope]
    if @scope == nil || @scope.strip == ""
      @scope = 'lastmonth'
    end

    sql = "select u.name as name, 
           u.id as userid,
           count(*) as number,
           sum(cost) as total_cost,
           sum(cost) / count(*) as per_unit"
    sql = sql + " from (select * from jobs where cost != 0"
    if @scope == 'running' 
      sql = sql + " and state in ('PowerOff', 'Run', 'Capturing')"
    elsif @scope == 'lastmonth'
      sql = sql + " and (updated_at > (now() - INTERVAL 1 MONTH) and state not in ('PowerOff', 'Run', 'Capturing'))"
    end
    sql = sql + " ) as j"
    sql = sql + " left join users u on u.id = j.user_id"
    sql = sql + " group by j.user_id"
    sql = sql + " order by #{@orderby} desc"    
  
    @records = Job.find_by_sql(sql)
  end
  
  def cost_by_team
    @orderby = params[:orderby]
    if @orderby == nil || @orderby.strip == ""
      @orderby = 'per_unit'
    end
    
    @scope = params[:scope]
    if @scope == nil || @scope.strip == ""
      @scope = 'lastmonth'
    end
    sql = "select u.name as name,
           u.id as userid,
           count(*) as number,
           sum(cost) as total_cost,
           sum(cost) / count(*) as per_unit
           from (select * from jobs where cost != 0"
    if @scope == 'running' 
      sql = sql + " and state in ('PowerOff', 'Run', 'Capturing')"
    elsif @scope == 'lastmonth'
      sql = sql + " and (updated_at > (now() - INTERVAL 1 MONTH) and state not in ('PowerOff', 'Run', 'Capturing'))"
    end
    sql = sql + " ) as j"
    sql = sql + " left join templates t on t.id = j.template_id"
    sql = sql + " left join users u on u.id = t.team_id"
    sql = sql + " group by u.id"
    sql = sql + " order by #{@orderby} desc"  
    @records = Job.find_by_sql(sql)
  end
  
  def cost_by_template
    @orderby = params[:orderby]
    if @orderby == nil || @orderby.strip == ""
      @orderby = 'per_unit'
    end
    
    @scope = params[:scope]
    if @scope == nil || @scope.strip == ""
      @scope = 'lastmonth'
    end
    sql = "select t.name,
           t.id,
           t.architecture,
          (case when t.image_size > 0 then 'EBS' else 'S3' end) as template_type,
          count(*) as number,
          sum(cost) as total_cost,
          sum(cost) / count(*) as per_unit
          from
          (select * from jobs where cost != 0 "
    if @scope == 'running' 
      sql = sql + " and state in ('PowerOff', 'Run', 'Capturing')"
    elsif @scope == 'lastmonth'
      sql = sql + " and (updated_at > (now() - INTERVAL 1 MONTH) and state not in ('PowerOff', 'Run', 'Capturing'))"
    end
    sql = sql + " ) as j"
    sql = sql + " left join templates t on t.id = j.template_id"
    sql = sql + " group by t.id"
    sql = sql + " order by #{@orderby} desc"  
    @records = Job.find_by_sql(sql)    
  end
  
  def machines_by_availablezone
    sql = "select instance_type, os, zone, 
           sum(case when state = 'running' then 1 else 0 end) as running,
           sum(case when state <> 'running' then 1 else 0 end) as no_running
           from active_machines 
           group by zone, instance_type, os
           order by instance_type, os, zone"
    @records = Job.find_by_sql(sql)       
  end
  
  def machines_in_availablezone
    sql = "select
             a.instance_id,
             a.instance_type,
             a.os,
             a.zone,
             a.security_group,
             j.deploymentway,
             j.created_at,
             j.id,
             j.usage,
             j.name,
             u.account
           from (select * from active_machines 
           where instance_type = '#{params[:instance_type]}' "
    sql += " and os = '#{params[:os]}'"
    sql += " and zone = '#{params[:zone]}' ) a "
    sql += " left join ec2machines e on a.instance_id = e.instance_id 
             left join jobs j on j.ec2machine_id = e.id
             left join users u on u.id = j.user_id"
    @records = Job.find_by_sql(sql)       
  end
  
  def dirty_ami
    sql = "select a.*, t.deleted, am.ic, t.updated_at, t.name as templatename
           from active_amis a
           left join templates t
           on a.ami_id = t.ec2_ami
           left join (select ami_id, count(*) as ic from active_machines group by ami_id) as am
           on am.ami_id = a.ami_id
           "
    is_deleted = params[:deleted]
    if !is_deleted.blank? 
      if is_deleted == '0'
         sql = sql + "where t.deleted is null"
      else
         sql = sql + "where t.deleted = 1"
      end
    else
      sql = sql + "where t.deleted is null or t.deleted = 1"
    end 
    sql = sql + " order by am.ic desc, t.updated_at desc"
    @records = Job.find_by_sql(sql)       
  end
  
  def dirty_snapshot
    sql = "select s.* from active_snapshots s
           left join active_amis a
           on s.ami = a.ami_id 
           "
    is_deleted = params[:deleted]
    if !is_deleted.blank? 
      if is_deleted == '0'
         sql = sql + "where s.ami is null"
      else
         sql = sql + "where s.ami is not null and a.name is null"
      end
    else
      sql = sql + "where s.ami is null or a.name is null"
    end 
    @records = Job.find_by_sql(sql)
  end
  
  def active_ami
    @records = ActiveAmi.find_by_sql("select am.*, t.id as template_id, t.name as template_name, t.deleted from active_amis am
    left join templates t
    on am.ami_id = t.ec2_ami")
  end

  def active_ebs
    @records = ActiveVolume.find(:all)    
  end
  def active_instance
    @records = ActiveMachine.find_by_sql(
      "select am.*, j.id as job_id, j.name as job_name, j.state as job_state, e.instance_id as job_instance
      from active_machines am
      left join jobs j
      on j.securitytype_name = am.security_group
      left join ec2machines e
      on e.id = j.ec2machine_id"
    )    
  end
  
  def active_snapshot
    @records = ActiveSnapshot.find(:all)
  end
  
  def templates_by_team
    @records = Template.find_by_sql("select u.name as team, count(*) as number from templates t left join users u on t.team_id = u.id where t.deleted = 0 group by t.team_id order by team")
  end
  
  def active_spot
    @records = ActiveSpot.find(:all)
  end  
end