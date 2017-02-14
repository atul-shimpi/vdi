require '/home/ec2-user/trunk/test/test_helper'

class JobTest < ActiveSupport::TestCase
 test "running_min_is_correct" do
   instance  = Ec2machine.new
   
   instance.local_launch_time = "Tue Jan 27 23:50:40 UTC 2015"
   puts "Instance running for #{instance.running_min}"

   assert (instance.running_min == 4)
 end 
 
 test "calc_running_min_is_launch_time_valid" do
    instance = Ec2machine.new
    
    assert (instance.running_min == -1)
  end

  test "running_for_hour?" do
    instance  = Ec2machine.new

    instance.local_launch_time = "Tue Jan 27 22:50:40 UTC 2015"

    assert(instance.running_for_hour?)
  end

 test "not_running_for_hour?" do
    instance  = Ec2machine.new

    instance.local_launch_time = "Tue Jan 27 23:50:40 UTC 2015"

    assert(instance.running_for_hour? == false)
  end

end
