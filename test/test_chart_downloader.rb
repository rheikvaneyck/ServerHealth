#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/Server-Health/chart_downloader'

class TestHealthCharts < Test::Unit::TestCase
  context "download charts" do
    setup do
      @cd = ServerHealth::ChartDownloader.new("../downloads","storage-")
    end
    should "return file path" do
       assert_equal "../downloads", @cd.download_path
    end
    should "return file name" do
       assert_match /\w*[-]*\d{4}(-\d{2}){4}/, @cd.file_name
    end
    should "download pie" do
      assert @cd.download_chart("http://chart.apis.google.com/chart?chs=450x300&cht=p&chco=00af33,4bb74c&chd=s:g9&chl=Used(35.00%25)|Free&chtt=HD+Space")
    end
  end
end

