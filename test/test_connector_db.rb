require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/Server-Health/db_connector'

class TestConnectorDB < Test::Unit::TestCase
  context "initialize the database" do
    setup do
      @db = ServerHealth::DBConnector.new("../db/logs-dev.sqlite")
    end
    should "return database enconding" do
      assert_not_nil @db.encoding
    end
    should "return missing tables" do
      assert @db.test_db_scheme(["log_files", "health_status"]).length >= 0
    end
  end
  context "creating tables" do
    setup do
      @db = ServerHealth::DBConnector.new("../db/logs-dev.sqlite")
    end
    should "return no missing tables" do
      table_hash = { :name => "log_files", :prim => true, :cols => { :file_name => "TEXT UNIQUE", :file_date => "DATE" } }
      @db.create_table(table_hash)
      assert_equal 0, @db.test_db_scheme(["log_files"]).length
    end
  end
  context "inserting data" do
    setup do
      @db = ServerHealth::DBConnector.new("../db/logs-dev.sqlite")
    end
    should "return inserted data" do
      data_hash = { :table => "log_files", :cols => { :file_name => "2011-06-03-HealthStatus.log", :file_date => "2011-06-03 06:50" } }
      @db.insert_data(data_hash)
      rows = @db.get_rows("log_files", ["file_name", "file_date"])
      puts rows.join(",")
      assert_not_equal 0, rows.length
    end
  end
end