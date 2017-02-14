class DemoJob < ActiveRecord::Base
  belongs_to :demo
  belongs_to :job   
  @config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
  def self.send_ready_mail(demojob)
    email = Email.new
    
    email.from = @config['demo_mailer.user_name']
    email.to = demojob.email
    email.cc = demojob.demo.demo_product.contact_mail + ", " + demojob.demo.demo_product.sales_mail
    
    content =  demojob.demo.demo_product.mail_template
    subject =  demojob.demo.demo_product.mail_subject
    email.content = apply_tokens(demojob, content)
    email.subject = apply_tokens(demojob, subject)
    email.mailer = 'demo_mailer'
    email.save    
  end
  
  def self.send_expired_mail(demojob)
    email = Email.new
    
    email.from = @config['demo_mailer.user_name']
    email.to = demojob.demo.demo_product.sales_mail
    email.cc = demojob.demo.demo_product.contact_mail
    
    email.subject = "[Demo Finished]The demo for " + demojob.name + " from " + demojob.company + " is finished"
    email.content = "The demo job for " + demojob.name + " from " + demojob.company + "is expired. He should have finished the demo test now.<br> Please contact " + demojob.email + " for next sale step."
    email.mailer = 'demo_mailer'
    email.save       
  end
  
  def self.send_lease_warning_mail(demojob)
    email = Email.new
    
    email.from = @config['demo_mailer.user_name']
    email.to = demojob.email
    email.cc = demojob.demo.demo_product.contact_mail + ", " + demojob.demo.demo_product.sales_mail
    
    email.subject = "[Demo Lease Warning]The demo you deployed for " + demojob.name + " will be expired soon"
    email.content = "The demo job you deployed for " + demojob.name + " will be expired in 24 hours. Please contact the sales team if you need more time to evaluate the demo."
    email.mailer = 'demo_mailer'
    email.save       
  end
  
  def self.apply_tokens(demojob, st)
    s = st
    s = s.gsub(/\$demo_product/, demojob.demo.demo_product.name)
    if demojob.job.ec2machine
      s = s.gsub(/\$machine_ip/, demojob.job.ec2machine.public_dns)
    elsif demojob.job.ilandmachine
      #If the job is iland machine
      s = s.gsub(/\$machine_ip/, demojob.job.ilandmachine.public_dns)
    else
      #Do nothing if there is no ec2machine nor ilandmachine
    end
    s = s.gsub(/\$machine_username/, demojob.job.template.user)
    s = s.gsub(/\$machine_password/, demojob.job.template.password)
    s = s.gsub(/\$request_name/, demojob.name)
    s = s.gsub(/\$demo_name/, demojob.demo.name)
  end
end