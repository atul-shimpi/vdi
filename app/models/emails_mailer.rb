require 'net/smtp'
begin
require 'smtp_tls'
rescue LoadError
end
class EmailsMailer < ActionMailer::Base
  @config = YAML.load_file(RAILS_ROOT + "/config/config.yml")
  @default_mailer = EmailsMailer.smtp_settings
  @demo_mailer = {
      :address => @config['demo_mailer.address'],
      :port => @config['demo_mailer.port'],
      :domain  => @config['demo_mailer.domain'],
      :authentication => :plain,
      :user_name => @config['demo_mailer.user_name'],
      :password => @config['demo_mailer.password']
  }
  def send(email)
    @email1 = email
    @subject = @email1.subject
    @from = @email1.from
    @content_type = "text/html"
    @send_on = Time.now
    @recipients = @email1.to if @email1.to != nil
    @bcc = @email1.bcc if @email1.bcc != nil
    @cc = @email1.cc if !@email1.cc.blank?
  end
  
  def self.set_to_demo_mailer 
    @@smtp_settings = @demo_mailer
  end
  def self.set_to_default_mailer
    @@smtp_settings = @default_mailer    
  end
end
