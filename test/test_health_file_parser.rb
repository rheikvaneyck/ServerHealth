require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/Server-Health/health_file_parser'

class TestHealthData < Test::Unit::TestCase
  context "parse health file" do
    setup do
      @health_data = ServerHealth::HealthData.new()
      @return_value = @health_data.parse_health_file("../downloads/2011-05-30-HealthStatus.log")
    end
    should "return success of parsing file" do
      assert @return_value
    end
    should "return raid status" do
      assert_equal("ok", @health_data.raid_state)
    end
    should "return error rates/counts" do
      [@health_data.hd1_Raw_Read_Error_Rate, @health_data.hd2_Raw_Read_Error_Rate, @health_data.hd1_Reallocated_Sector_Ct, @health_data.hd2_Reallocated_Sector_Ct, @health_data.hd1_Offline_Uncorrectable, @health_data.hd2_Offline_Uncorrectable, @health_data.hd1_Reallocated_Event_Count, @health_data.hd2_Reallocated_Event_Count].each do |hdata|
        assert_match(/\d+/, hdata)
      end
    end
    should "return runtime values" do
      [@health_data.hd1_run_time, @health_data.hd2_run_time].each do |rt|
        assert_match(/\d+/, rt)
      end
    end
    should "return HD error test" do
      [@health_data.hd1_error_state, @health_data.hd2_error_state].each do |es|
        assert_equal("Completed without error", es)        
      end      
    end    
    should "return used/free diskspace in Bytes" do
        [@health_data.hd_space_used, @health_data.hd_space_left].each do |space|
        assert_match(/\d+/, space)
      end
    end
  end
end
