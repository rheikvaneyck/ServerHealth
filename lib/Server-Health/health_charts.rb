#!/usr/bin/env ruby
require 'google_chart'

module ServerHealth
  class HDRuntimeChart
    attr_accessor :size, :title, :data1_color, :data2_color, :data1_title, :data2_title
    attr_accessor :hd1_data, :hd2_data, :data_labels
    
    def initialize(hd1_data = [], hd2_data = [], data_labels = [], size = '450x300', title = "runtime")
      @url = ""
      @hd1_data = hd1_data
      @hd2_data = hd2_data
      @data_labels = data_labels
      @size = size
      @title = title
      @xy_chart = false
      @data1_color = '0000ff'
      @data2_color = 'ff0000'
      @data1_title = "HD1 runtime (h)"
      @data2_title = "HD2 runtime (h)"
    end
    
    def get_url
      GoogleChart::LineChart.new(@size, @title, @xy_chart) do |lc|
        lc.data @data1_title, @hd1_data, @data1_color
        lc.data @data2_title, @hd2_data, @data2_color
        lc.data_encoding = :text
        #lc.max_value to_value
        lc.axis :y, :labels => @data_labels, :color => 'cccccc', :font_size => 16, :alignment => :center
        @url = lc.to_url
      end
      return @url
    end
  end
  
  class StoragePie
    attr_accessor :size, :title, :used_color, :free_color, :used_title, :free_title
    attr_accessor :used_value, :free_value
    
    def initialize(used_value = 0.0, free_value = 0.0, size = '450x300', title = "HD Space")
      @url = ""
      @used_value = used_value
      @free_value = free_value
      @used_title = "Used(" + sprintf("%1.2f",(@used_value*100)/(@free_value+@used_value)) +"%)"
      @free_title = "Free"
      @size = size
      @title = title
      @used_color = '00AF33'
      @free_color = '4BB74C'
    end
    
    def get_url
      GoogleChart::PieChart.new(@size, @title) do |pc|
        pc.data @used_title, @used_value, @used_color
        pc.data "Free", @free_value, @free_color
        @url = pc.to_url
      end
      return @url
    end
  end
  
  class StorageHistoryChart
    attr_accessor :size, :title, :data_color, :data_title
    attr_accessor :storage_data, :data_labels, :time_labels
    
    def initialize(storage_data = [], data_labels = [], time_labels = [], size = '450x300', title = "Storage over Time")
      @url = ""
      @storage_data = storage_data
      @data_labels = data_labels
      @time_labels = time_labels
      @size = size
      @title = title
      @xy_chart = true
      @data_color = '0000ff'
      @data_title = "Storage consumption"
    end
    
    def get_url
      GoogleChart::LineChart.new(@size, @title, @xy_chart) do |lcxy|
        lcxy.data @data_title, @storage_data, @data_color
        lcxy.data_encoding = :text
        lcxy.axis :y, :labels => @data_labels, :color => 'cccccc', :font_size => 16, :alignment => :center
        lcxy.axis :x, :labels => @time_labels, :color => 'cccccc', :font_size => 16, :alignment => :center
        @url = lcxy.to_url
      end
      puts @url
      return @url
    end
  end
end
