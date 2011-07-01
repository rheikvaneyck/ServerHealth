#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/Server-Health/chart_downloader'

class TestHealthCharts < Test::Unit::TestCase
  context "download charts" do
    setup do
      @cd = ServerHealth::ChartDownloader.new()
    end
    should "return file path" do
       assert_equal "../downloads", @cd.download_path
    end
    should "return file name" do
       assert_match /\w*[-]*\d{4}(-\d{2}){4}/, @cd.file_name
    end
  end
end

