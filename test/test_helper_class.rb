require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/helper_class'

class TestHelperClass < Test::Unit::TestCase
  context "helper class methods" do
    setup do
      @hc = Helper::HelperClass.new()
    end
    should "return success of parsing file" do
      assert_equal "2011-03-18 06:00:00 +0100", @hc.timestamp_from_filename("2011-03-18-HealthStatus.log").to_s
    end
  end
end

