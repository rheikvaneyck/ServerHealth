require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/Server-Health/log_downloader'

class TestLogDownloader < Test::Unit::TestCase
  context "import log dir listing" do
    setup do
      @log_downloader = ServerHealth::LogDownloader.new("localhost", "rubyuser", "#Volvic#")
    end
    should "return nr of differences" do
      assert_equal 1, @log_downloader.kick_existing_items([1,2,3],[1,2])
    end
    should "return host name of remote host" do
      assert_not_nil @log_downloader.get_remote_hostname()
    end
    should "return number of imported files" do
      long_file_list = @log_downloader.get_remote_log_list("/var/log/health")
      file_list = []
      @log_downloader.import_file_list(file_list, long_file_list)
      assert_not_equal 0, file_list.length
    end
    should "return number of downloaded logs" do
      assert_not_equal 0, @log_downloader.download_new_logs("/var/log/health", "../downloads")
    end
  end
end
