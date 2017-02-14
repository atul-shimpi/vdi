require 'rubygems'
require 'mysql'
require 'httpclient'
require "rexml/document"
require 'logger'


class Hash
  def except(which)
    self.tap{ |h| h.delete(which) }
  end
end

target = "https://dal01.ilandcloud.com/api/v1.0/login"
clnt = HTTPClient.new
clnt.set_auth(target, "Kinson@Versata-11088987", "JGnKSXtmHnLA")
clnt.set_cookie_store("cookie.dat")
result = clnt.post_content(target)
#puts result
clnt.save_cookie_store


result = clnt.get("https://dal01.ilandcloud.com/api/vdc/c5f83bee-d9d3-4228-bd07-0d25ed3e3596").body
doc = REXML::Document.new result

vdijob = Hash.new
doc.elements.each("*/ResourceEntities/ResourceEntity") { |element| 
	if element.attributes["name"].start_with?("vdijob_")
		#puts element.attributes["name"].split("_")[1]
		vdijob.store(element.attributes["name"].split("_")[1],element.attributes["href"] )
	end
}

begin

con = Mysql.new 'vdi-db.devfactory.com', 'root',  'U82YFoh5DtDiZTRf', 'gdevvdi' 

vdijob.each { |elem|
	rs = con.query("SELECT state FROM gdevvdi.jobs where id = #{elem[0]}")
	state = String.new rs.fetch_row[0]
	if state == "Build Fail" || state == "Expired" || state == "Undeploy"
		#puts "not removed #{state}" 
	else
		vdijob = vdijob.except(elem[0])
		#puts "removed #{state}" 
	end
	#puts state
}

log = Logger.new('./ilandcleanup.log')
#log.level = Logger::WARN

vdijob.each { |elem|
rs = con.query("SELECT state FROM gdevvdi.jobs where id = #{elem[0]}")
result = clnt.delete(elem[1]).code
puts "#{elem[0]}, #{rs.fetch_row}, #{result}"
log.info("#{elem[0]}, #{rs.fetch_row}, #{result}")

}
rescue Mysql::Error => e
    puts e.errno
    puts e.error
    
ensure
    con.close if con
end



