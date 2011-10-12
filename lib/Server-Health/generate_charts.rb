#!/usr/bin/env ruby
require 'gchart'

module ServerHealth
  class HDRuntimeChart
    attr_accessor :size, :title, :data1_color, :data2_color, :data1_legend, :data2_legend
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
      @data1_legend = "HD1 runtime (h)"
      @data2_legend = "HD2 runtime (h)"
    end
    
    def get_url
      @url = Gchart.line(:theme => :thirty7signals,
                         :data => [@hd1_data, @hd2_data],
                         :axis_with_labels => ['x','y'],
                         :axis_labels => @data_labels,
                         :title => @title,
                         :legend => [@data1_legend, @data2_legend],
                         :size => @size)
      return @url
    end
    def save_chart_to_file(filename)
      @url = Gchart.line(:theme => :thirty7signals,
                         :data => [@hd1_data, @hd2_data],
                         :axis_with_labels => ['x','y'],
                         :axis_labels => @data_labels,
                         :title => @title,
                         :legend => [@data1_legend, @data2_legend],
                         :size => @size,
                         :format => 'file', :filename => filename)
      return @url
    end
  end
  class StorageHistoryChart
    attr_accessor :size, :title, :data_color, :data_legend
    attr_accessor :storage_data, :data_labels, :time_labels
    
    def initialize(storage_data = [], time_labels = [], data_labels = [], size = '450x300', title = "Storage over Time")
      @url = ""
      @storage_data = storage_data
      @time_labels = time_labels
      @data_labels = data_labels
      @size = size
      @title = title
      @data_color = '0000ff'
      @data_legend = "Storage consumption"
    end
    
    def get_url
      @url = Gchart.line_xy(:theme => :thirty7signals,
                            :data => @storage_data,
                            :axis_with_labels => ['x','y'],
                            :axis_labels => [@time_labels,@data_labels],
                            :title => @title,
                            :legend => @data_legend,
                            :size => @size)
      return @url
    end
    def save_chart_to_file(filename)
      @url = Gchart.line_xy(:theme => :thirty7signals,
                            :data => @storage_data,
                            :axis_with_labels => ['x','y'],
                            :axis_labels => [@time_labels,@data_labels],
                            :title => @title,
                            :legend => @data_legend,
                            :size => @size,
                            :format => 'file', :filename => filename)
      return @url
    end
  end
  
  class StoragePie
    attr_accessor :size, :title, :used_color, :free_color, :used_legend, :free_legend
    attr_accessor :used_value, :free_value
    
    def initialize(used_value = 0.0, free_value = 0.0, size = '450x300', title = "HD Space")
      @url = ""
      @used_value = used_value
      @free_value = free_value
      @used_legend = "Used(" + sprintf("%1.2f",(@used_value*100)/(@free_value+@used_value)) +"%)"
      @free_legend = "Free"
      @size = size
      @title = title
      @used_color = '00AF33'
      @free_color = '4BB74C'
    end
    
    def get_url
      @url = Gchart.pie(:title => @title,
                           :labels => [@used_legend, @free_legend],
                           :data => [@used_value,@free_value],
                           :size => @size)
      return @url
    end
    def save_chart_to_file(filename)
      chart = Gchart.pie(:theme => :pastel,
                            :title => @title,
                           :labels => [@used_legend, @free_legend],
                           :data => [@used_value,@free_value],
                           :size => @size,
                           :format => 'file', :filename => filename)
      return chart
    end
  end
  
  class StoragePie3D
    attr_accessor :size, :title, :used_color, :free_color, :used_legend, :free_legend
    attr_accessor :used_value, :free_value
    
    def initialize(used_value = 0.0, free_value = 0.0, size = '580x300', title = "HD Space")
      @url = ""
      @used_value = used_value
      @free_value = free_value
      @used_legend = "Used(" + sprintf("%1.2f",(@used_value*100)/(@free_value+@used_value)) +"%)"
      @free_legend = "Free"
      @size = size
      @title = title
      @used_color = '00AF33'
      @free_color = '4BB74C'
    end
    
    def get_url
      @url = Gchart.pie_3d(:title => @title,
                           :labels => [@used_legend, @free_legend],
                           :data => [@used_value,@free_value],
                           :size => @size)
      return @url
    end
    def save_chart_to_file(filename)
      chart = Gchart.pie_3d(:theme => :pastel,
                            :title => @title,
                           :labels => [@used_legend, @free_legend],
                           :data => [@used_value,@free_value],
                           :size => @size,
                           :format => 'file', :filename => filename)
      return chart
    end
  end
end
