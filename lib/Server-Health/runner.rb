#!/usr/bin/env ruby
require_relative '../helper_class'
require_relative 'options'
require_relative 'credentials'
require_relative 'log_downloader'
require_relative 'health_file_parser'
# require_relative 'db_connector' is obsolete!!!
require_relative 'db_manager'

module ServerHealth
  class Runner
    
    def initialize(argv)
      @options = Options.new(argv)
      @db = ServerHealth::DBManager.new(File.join(@options.database_dir, @options.database_file))
      @hc = Helper::HelperClass.new()
    end
    
    def run
      # Download Log Files
      file_list = []
      exclude_list = @db.get_column(ServerHealth::DBManager::LogFile, :file_name) # get in here the files that are allready in the database
      
      cobj = ServerHealth::Credentials.new()
      credentials = cobj.read_from_yaml(File.join(@options.config_dir,@options.credential_file),["ssh_user", "ssh_pw", "ssh_server"])
      
      log_downloader = ServerHealth::LogDownloader.new(credentials[:ssh_server],credentials[:ssh_user],credentials[:ssh_pw])
      file_list = log_downloader.download_new_logs(@options.remote_log_dir, @options.local_log_dir, exclude_list)
      
      # Insert the log files and timestamps into the DB
      health_data = ServerHealth::HealthData.new()
      file_list.sort.each do |file|
        log_file = nil
        timestamp = ""
        begin
          timestamp = @hc.timestamp_from_filename(file).to_s
          health_data.parse_health_file(File.join(@options.local_log_dir, file))
          log_file = @db.insert_record(ServerHealth::DBManager::LogFile, {:file_name => file, :file_date => timestamp})
          puts "Log file #{file} imported" if $DEBUG
        rescue
          puts "couldn't process #{file} for import in table 'log_files'"         
        end
        begin
          @db.insert_record(ServerHealth::DBManager::HealthState, {
            :file_id => log_file.id,
            :raid_state => health_data.raid_state,
            :hd1_error_state => health_data.hd1_error_state,
            :hd2_error_state => health_data.hd2_error_state,
            :hd1_Raw_Read_Error_Rate => health_data.hd1_Raw_Read_Error_Rate,
            :hd2_Raw_Read_Error_Rate => health_data.hd2_Raw_Read_Error_Rate,
            :hd1_Reallocated_Sector_Ct => health_data.hd1_Reallocated_Sector_Ct,
            :hd2_Reallocated_Sector_Ct => health_data.hd2_Reallocated_Sector_Ct,
            :hd1_Offline_Uncorrectable => health_data.hd1_Offline_Uncorrectable,
            :hd2_Offline_Uncorrectable => health_data.hd2_Offline_Uncorrectable,
            :hd1_Reallocated_Event_Count => health_data.hd1_Reallocated_Event_Count,
            :hd2_Reallocated_Event_Count => health_data.hd2_Reallocated_Event_Count,
            :hd1_run_time => health_data.hd1_run_time,
            :hd2_run_time => health_data.hd2_run_time,
            :hd_space_used => health_data.hd_space_used,
            :hd_space_left => health_data.hd_space_left
          } unless log_file.nil?
          puts "Health file #{file} imported" if $DEBUG
        rescue
          puts "couldn't process #{file} for import in table 'health_states"         
        end          
      end
            
      # Visualize Data
      # 1. Storage Pie
      current_health_state = ServerHealth::DBManager::HealthState.find(:last)
      hd_space_used = current_health_state.hd_space_used
      hd_space_left = current_health_state.hd_space_left
      @c = ServerHealth::StoragePie.new(hd_space_used,hd_space_left)
      storage_pie_url = @c.get_url
      @cd = ServerHealth::ChartDownloader.new(@options.reports_dir,"storage-")
      @cd.download_chart(storage_pie_url)
      template_file = File.join(@options.reports_dir, @options.report_template)
      values_reported = { 
        :hd1_error_state => current_health_state.hd1_error_state,
        :hd2_error_state => current_health_state.hd2_error_state,
        :hd1_Raw_Read_Error_Rate => current_health_state.hd1_Raw_Read_Error_Rate,
        :hd2_Raw_Read_Error_Rate => current_health_state.hd2_Raw_Read_Error_Rate,
        :hd1_Reallocated_Sector_Ct => current_health_state.hd1_Reallocated_Sector_Ct,
        :hd2_Reallocated_Sector_Ct => current_health_state.hd2_Reallocated_Sector_Ct,
        :hd1_Offline_Uncorrectable => current_health_state.hd1_Offline_Uncorrectable,
        :hd2_Offline_Uncorrectable => current_health_state.hd2_Offline_Uncorrectable,
        :hd1_Reallocated_Event_Count => current_health_state.hd1_Reallocated_Event_Count,
        :hd2_Reallocated_Event_Count => current_health_state.hd2_Reallocated_Event_Count,
        :storage_pie_path => "../downloads/chart-2011-07-01-20-49.png"
      }
      @report = ServerHealth::Report.new(template_file, values_reported)
    end
    should "exist" do
       report_file = Time.now.strftime("%Y-%m-%d-report.html")
       @report.generate(report_file)

      # Generate Rport
      
      
      # Send Report
      
      puts "Finished."
    end
  end
end
