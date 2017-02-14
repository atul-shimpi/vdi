class Ilandmachine < ActiveRecord::Base
  has_many :jobs
  
  def is_publicdns_valid
    #TODO: the ip checker should be optimized
    if public_dns==nil||public_dns==""
      return false
    end
    ipnums = public_dns.split('.')  
    if ipnums.size == 4
      return true
    else 
      return false
    end
  end
  
  def self.is_valid_ip(ip)
    #TODO: the ip checker should be optimized    
    ipnums = ip.split('.')
    if ipnums.size ==4
      return true
    else 
      return false
    end
  end
end