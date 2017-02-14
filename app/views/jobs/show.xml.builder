xml.instruct!
xml.vdijob do
  xml.id @job.id
  xml.state @job.state
  xml.public_dns @machine.public_dns if @machine
  xml.private_dns @machine.private_dns if @machine
  xml.initcommands @job.init_commands
  xml.username @tempalte.user
  xml.password @tempalte.password
end
