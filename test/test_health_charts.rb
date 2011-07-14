#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/Server-Health/health_charts'

class TestHealthCharts < Test::Unit::TestCase
  context "get HD runtime charts" do
    setup do
      @c = ServerHealth::HDRuntimeChart.new([10,20,30,40,50],[10,30,50,70,90], (0..100).step(10).to_a)
    end
    should "return initial data" do
      assert_equal '450x300', @c.size
      assert_equal 'runtime', @c.title
      # assert_equal false, @c.xy_chart
      assert_equal '0000ff', @c.data1_color
      assert_equal 'ff0000', @c.data2_color
      assert_equal "HD1 runtime (h)", @c.data1_title
      assert_equal "HD2 runtime (h)", @c.data2_title
      assert_equal 5, @c.hd1_data.length
      assert_equal 5, @c.hd2_data.length
      assert_equal 11, @c.data_labels.length
    end
    should "return the chart url and no empty string" do
      assert_not_equal "", @c.get_url
    end
  end
  context "get space pie" do
    setup do
      @c = ServerHealth::StoragePie.new(35.0,65.0)
    end
    should "return initial data" do
      assert_equal '450x300', @c.size
      assert_equal 'HD Space', @c.title
      assert_equal '00AF33', @c.used_color
      assert_equal '4BB74C', @c.free_color
      assert_equal "Used(35.00%)", @c.used_title
      assert_equal "Free", @c.free_title
      assert_equal 35.0, @c.used_value
      assert_equal 65.0, @c.free_value
    end
    should "return the pie url and no empty string" do
      assert_not_equal "", @c.get_url
    end
  end
  context "get storage over time chart" do
    setup do
      @c = ServerHealth::StorageHistoryChart.new([[10,20,30,40,50],[1,2,3,4,5]], (0..100).step(10).to_a, %w{1 2 3 4 5})
    end
    should "return initial data" do
      assert_equal '450x300', @c.size
      assert_equal "Storage over Time", @c.title
      assert_equal '0000ff', @c.data_color
      assert_equal "Storage consumption", @c.data_title
    end
    should "return the chart url and no empty string" do
      assert_not_equal "", @c.get_url
    end
  end
end

