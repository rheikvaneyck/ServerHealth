#!/usr/bin/env ruby
require 'erb'

module ServerHealth
  class Report
    def initialize(template_file, values_reported)
      @server = values_reported[:server_name]
      @hd1_error_state = values_reported[:hd1_error_state]
      @hd2_error_state = values_reported[:hd2_error_state]
      @hd1_Raw_Read_Error_Rate = values_reported[:hd1_Raw_Read_Error_Rate]
      @hd2_Raw_Read_Error_Rate = values_reported[:hd2_Raw_Read_Error_Rate]
      @hd1_Reallocated_Sector_Ct = values_reported[:hd1_Reallocated_Sector_Ct]
      @hd2_Reallocated_Sector_Ct = values_reported[:hd2_Reallocated_Sector_Ct]
      @hd1_Offline_Uncorrectable = values_reported[:hd1_Offline_Uncorrectable]
      @hd2_Offline_Uncorrectable = values_reported[:hd2_Offline_Uncorrectable]
      @hd1_Reallocated_Event_Count = values_reported[:hd1_Reallocated_Event_Count]
      @hd2_Reallocated_Event_Count = values_reported[:hd2_Reallocated_Event_Count]
      @storage_pie_path = values_reported[:storage_pie_path] 
           
      @template = File.read(template_file)
    end
    
    def generate(report_file)
      b = binding
      @html_file = ERB.new(@template)
      @report = @html_file.result b
      File.open(report_file,'w') do |f|
        f.write(@report)
      end      
    end
  end
end
