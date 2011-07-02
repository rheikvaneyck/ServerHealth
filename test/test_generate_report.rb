#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/Server-Health/generate_report'

class TestGenerateReport < Test::Unit::TestCase
  context "generate report" do
    setup do
      template_file = "../reports/report_template.html.erb"
      values_reported = { 
        :hd1_error_state => "No Error",
        :hd2_error_state => "No Error",
        :hd1_Raw_Read_Error_Rate => 0,
        :hd2_Raw_Read_Error_Rate => 0,
        :hd1_Reallocated_Sector_Ct => 0,
        :hd2_Reallocated_Sector_Ct => 0,
        :hd1_Offline_Uncorrectable => 0,
        :hd2_Offline_Uncorrectable => 0,
        :hd1_Reallocated_Event_Count => 0,
        :hd2_Reallocated_Event_Count => 0,
        :storage_pie_path => "../downloads/chart-2011-07-01-20-49.png"
      }
      @report = ServerHealth::Report.new(template_file, values_reported)
    end
    should "exist" do
       report_file = Time.now.strftime("%Y-%m-%d-report.html")
       @report.generate(report_file)
       assert File.exist?(File.join("../reports",report_file))
    end
  end
end

