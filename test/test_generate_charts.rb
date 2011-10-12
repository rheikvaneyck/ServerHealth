#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/Server-Health/generate_charts'

class TestGenerateCharts < Test::Unit::TestCase
  context "get space 3D-pie" do
    setup do
      @c = ServerHealth::StoragePie3D.new(35.0,65.0)
    end
    should "return initial data" do
      assert_equal '580x300', @c.size
      assert_equal 'HD Space', @c.title
      assert_equal '00AF33', @c.used_color
      assert_equal '4BB74C', @c.free_color
      assert_equal "Used(35.00%)", @c.used_legend
      assert_equal "Free", @c.free_legend
      assert_equal 35.0, @c.used_value
      assert_equal 65.0, @c.free_value
    end
    should "return the pie url and no empty string" do
      assert_not_equal "", @c.get_url
    end
    should "return the file size of downloaded chart png" do
      file_size = @c.save_chart_to_file("/tmp/chart3D.png")
      assert_not_equal 0, file_size
    end

  end
  context "get space 2D-pie" do
    setup do
      @c = ServerHealth::StoragePie.new(35.0,65.0)
    end
    should "return initial data" do
      assert_equal '450x300', @c.size
      assert_equal 'HD Space', @c.title
      assert_equal '00AF33', @c.used_color
      assert_equal '4BB74C', @c.free_color
      assert_equal "Used(35.00%)", @c.used_legend
      assert_equal "Free", @c.free_legend
      assert_equal 35.0, @c.used_value
      assert_equal 65.0, @c.free_value
    end
    should "return the pie url and no empty string" do
      assert_match /chart\.apis\.google\.com/, @c.get_url
    end
    should "return the pie url and no empty string" do
      file_size = @c.save_chart_to_file("/tmp/chart.png")
      assert_not_equal 0, file_size
    end
  end
  context "get HD runtime charts" do
    setup do
      @c = ServerHealth::HDRuntimeChart.new([8232,8256,8321,8352,8390],[10120,11030,11520,11870,12090], [(1..5).to_a, (0..13000).step(2000).to_a])
    end
    should "return initial data" do
      assert_equal '450x300', @c.size
      assert_equal 'runtime', @c.title
      # assert_equal false, @c.xy_chart
      assert_equal '0000ff', @c.data1_color
      assert_equal 'ff0000', @c.data2_color
      assert_equal "HD1 runtime (h)", @c.data1_legend
      assert_equal "HD2 runtime (h)", @c.data2_legend
      assert_equal 5, @c.hd1_data.length
      assert_equal 5, @c.hd2_data.length
      assert_equal 2, @c.data_labels.length
    end
    should "return the chart url and no empty string" do
      url = @c.get_url
      assert_match /chart\.apis\.google\.com/, url
    end
    should "return the file size of downloaded chart png" do
      file_size = @c.save_chart_to_file("/tmp/line_chart.png")
      assert_not_equal 0, file_size
    end
  end
  context "get storage over time chart" do
    setup do
      @c = ServerHealth::StorageHistoryChart.new([[10,20,30,40,50],[5,20,25,40,50]],  %w{0 1 2 3 4 5}, (0..50).step(10).to_a)
    end
    should "return initial data" do
      assert_equal '450x300', @c.size
      assert_equal "Storage over Time", @c.title
      assert_equal '0000ff', @c.data_color
      assert_equal "Storage consumption", @c.data_legend
    end
    should "return the chart url and no empty string" do
      url = @c.get_url
      assert_match /chart\.apis\.google\.com/, url
    end
    should "return the file size of downloaded chart png" do
      file_size = @c.save_chart_to_file("/tmp/line_xy_chart.png")
      assert_not_equal 0, file_size
    end
  end
end

