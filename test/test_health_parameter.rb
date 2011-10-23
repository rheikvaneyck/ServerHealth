#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/Server-Health/health_parameter'

class TestCredentials < Test::Unit::TestCase
  context "reading parameter from file" do
    should "return RAID regexps" do
      raid_keys = ["RAID"]
      raid_parameter = ServerHealth::HealthParameter.read_from_yaml("../config/health_parameter.yml",raid_keys)
      assert_equal '^name\s+:\s+(\w+)', raid_parameter[:RAID]['raid_name']
      assert_equal '^devs\s+:\s+(\w+)', raid_parameter[:RAID]['raid_devs']
      assert_equal '^type\s+:\s+(\w+)', raid_parameter[:RAID]['raid_type']
      assert_equal '^status\s+:\s(\w+)', raid_parameter[:RAID]['raid_state']
    end
    should "return SMARTT regexps" do
      raid_keys = ["SMARTT"]
      raid_parameter = ServerHealth::HealthParameter.read_from_yaml("../config/health_parameter.yml",raid_keys)
      assert_equal 'Device Model:\s+([\s\w-]+)', raid_parameter[:SMARTT]['device_model']
      assert_equal 'Serial Number:\s+([\s\w-]+)', raid_parameter[:SMARTT]['serial_number']
      assert_equal 'Raw_Read_Error_Rate\.\s+(\d+)', raid_parameter[:SMARTT]['raw_read_error_rate']
      assert_equal 'Reallocated_Sector_Ct\.\s+(\d+)', raid_parameter[:SMARTT]['reallocated_sector_count']
      assert_equal 'Offline_Uncorrectable\.\s+(\d+)', raid_parameter[:SMARTT]['offline_uncorectable']
      assert_equal 'Reallocated_Event_Count\.\s+(\d+)', raid_parameter[:SMARTT]['reallocated_event_count']
      assert_equal '#\s+1\s+Short offline\s+(\d+)\s+', raid_parameter[:SMARTT]['error_state']
    end
    should "return DISK regexps" do
      raid_keys = ["DISK"]
      raid_parameter = ServerHealth::HealthParameter.read_from_yaml("../config/health_parameter.yml",raid_keys)
      assert_equal '/dev/sda', raid_parameter[:DISK]['disks'][0]
      assert_equal '/dev/sdb', raid_parameter[:DISK]['disks'][1]
      assert_equal '(\d+)\s+(\d+)\s+%\s+(\/)$', raid_parameter[:DISK]['storage']
      assert_equal 'storage-0', raid_parameter[:DISK]['storage_used']
      assert_equal 'storage-1', raid_parameter[:DISK]['storage_free']
      assert_equal 'storage-2', raid_parameter[:DISK]['mount_point']
    end
  end
end