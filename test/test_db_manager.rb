require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/Server-Health/db_manager'

class TestDBManager < Test::Unit::TestCase
  context "database" do
    setup do
      @db = ServerHealth::DBManager.new("../db/logs-dev.sqlite")
    end
    should "return connection state" do
      assert @db.connection_state?
    end
    should "return table log_files existens" do
      assert @db.table_exists?("log_files"), "Table log_files does not exist"
    end
    should "return table health_states existens" do
      assert @db.table_exists?("log_files"), "Table health_states does not exist"
    end
    should "be able to insert values to log_files" do
      # log_file = ServerHealth::DBManager::LogFile.create(:file_name => "2011-03-18-HealthStatus.log", :file_date => "2011-10-05 22:00:00 +0200")
      log_file = @db.insert_record(ServerHealth::DBManager::LogFile, {:file_name => "2011-03-18-HealthStatus.log", :file_date => "2011-10-05 22:00:00 +0200"})
      assert_equal "2011-03-18-HealthStatus.log", ServerHealth::DBManager::LogFile.find(log_file.id).file_name
    end
    should "return column file_name from log_files" do
      @db.insert_record(ServerHealth::DBManager::LogFile, {:file_name => "2011-10-20-HealthStatus.log", :file_date => "2011-10-20 22:00:00 +0200"})
      assert !@db.get_column(ServerHealth::DBManager::LogFile, :file_name).empty?, "column is empty"
    end
    teardown do
      ServerHealth::DBManager::LogFile.find_each do |l|
        l.destroy
      end     
    end
  end
end

