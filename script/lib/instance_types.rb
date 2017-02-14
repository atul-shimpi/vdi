# ******************************************************************************************************************************************
# Createion Timestamp : 14/Dec/2014 09:40
# Author              : Atul Shimpi (atul.shimpi@gteamstaff.com)
# Purpose             : Updated ec2 ami prices in the vdi database
# Descriptoin         : Reads ami prices from https://raw.githubusercontent.com/powdahound/ec2instances.info/master/www/instances.json
#                     : and updates prices for each instance type in vdi database
# ******************************************************************************************************************************************

require 'rubygems'
require 'open-uri'
require 'json'
require 'pp'

require  File.join(APP_DIR, 'script/lib/setup')
require File.join('config', 'environment')

EC2_AMI_PRICES_URL='https://raw.githubusercontent.com/powdahound/ec2instances.info/master/www/instances.json'
NORTH_VIRGINIA='us-east-1'
PRICING='pricing'
WINDOWS='mswin'
LINUX='linux'

class InstanceTypes
  def self.update_prices
    @@logger.info("Started updating Instance Types prices at #{Time.now}")

    request_query = ''
    url = "#{EC2_AMI_PRICES_URL}#{request_query}"
    buffer = open(url).read
    amazon_instance_types = JSON.parse(buffer)
 
    vdi_instance_types_count = 0 
    vdi_instance_types = Instancetype.all 
    vdi_instance_price_found = false;

    vdi_instance_types.each do |vdi_instance_type| # //1
      vdi_instance_types_count = vdi_instance_types_count + 1
      prices = "#{vdi_instance_types_count}) #{vdi_instance_type.name}"

      amazon_instance_types.each do |amazon_instance_image| # //2
        if vdi_instance_type.name == amazon_instance_image['instance_type'] # //3
          vdi_instance_price_found = true
          
          # windows ami price
          win_price = ''
          win_price = amazon_instance_image[PRICING][NORTH_VIRGINIA][WINDOWS]
          if not win_price.empty?
            prices = prices + " Windows Price = #{win_price.to_s}"
            vdi_instance_type.windows_price = win_price.to_f
          end

          # linux ami price
          linux_price = ''
          linux_price = amazon_instance_image[PRICING][NORTH_VIRGINIA][LINUX]
          if not linux_price.empty?
            prices = prices + " Linux Price = #{linux_price}"
            vdi_instance_type.linux_price = linux_price.to_f
          end 

          if vdi_instance_type.changed?
            if vdi_instance_type.save
              @@logger.info("Updated prices for #{vdi_instance_type.name}")
            else
              @@logger.info("Error encounetered while updating prices for #{vdi_instance_type.name}")
            end
          end
         
         break;        
        end # //3
      end # //2

      @@logger.info("No Price found for #{vdi_instance_type.name}") if not vdi_instance_price_found
      vdi_instance_price_found = false

    end # //1
  end
  
  def self.import
    @@logger.info("Starting importing instances")
    
    request_query = ''
    url = "#{EC2_AMI_PRICES_URL}#{request_query}"
    buffer = open(url).read
    amazon_instance_types = JSON.parse(buffer)
   
    amazon_instance_types.each do |amazon_instance|
      no_of_cpus = amazon_instance['vCPU'].to_i
      memory = amazon_instance['memory'].to_i
      description = "#{no_of_cpus} vCPUs - #{memory} GiB"
    
      amazon_instance['arch'].each do |arch|
        if Instancetype.exists?(:name => amazon_instance['instance_type'], :architecture => arch)
          instance = Instancetype.find(:first, :conditions => "name = '#{amazon_instance['instance_type']}' and architecture = '#{arch}'") 
          Instancetype.update(instance.id,
                              :description => description,
                              :cpusize => no_of_cpus,
                              :memorysize => memory,
                              :windows_price => amazon_instance[PRICING][NORTH_VIRGINIA][WINDOWS],
                              :linux_price => amazon_instance[PRICING][NORTH_VIRGINIA][LINUX]
                              ) 
         
         @@logger.info("Updated " + instance.name + " - " + instance.description) 
       else
         instance = Instancetype.new
         
         instance.name = amazon_instance['instance_type']
         instance.architecture = arch
         instance.description = description
         instance.cpusize = no_of_cpus
         instance.memorysize = memory
         instance.dc = "ec2"
         instance.windows_price = win_price = amazon_instance[PRICING][NORTH_VIRGINIA][WINDOWS]
         instance.windows_maxprice = 0
         instance.linux_price = win_price = amazon_instance[PRICING][NORTH_VIRGINIA][LINUX]
         instance.linux_maxprice = 0
         instance.seq = 0
         instance.save
         
         @@logger.info("Added " + instance.name + " - " + instance.description)
       end
      end  
    end

    @@logger.info("Importing instances completed")    
  end

end
