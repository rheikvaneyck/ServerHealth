#!/usr/bin/env ruby
require_relative '../helper_class'
require_relative 'options'
require_relative 'credentials'
require_relative 'log_downloader'
require_relative 'health_file_parser'
# require_relative 'db_connector' is obsolete!!!
require_relative 'db_manager'
require_relative 'chart_downloader'
require_relative 'generate_report'
require_relative 'generate_email'
require_relative 'send_report'

module ServerHealth
  class Runner
    
    def initialize(argv)
      @options = Options.new(argv)
      @db = ServerHealth::DBManager.new(File.join(@options.database_dir, @options.database_file))
    end
    
    def run
      # Download Log Files
      # file_list = download_log_files
      # initial load if log files already downloaded 
      file_list = Dir[File.join(@options.local_log_dir,"*.log")]
      
      # Insert the log files and timestamps into the DB
      import_log_files file_list
      
      # Visualize Data
      # 1. Storage Pie
      storage_pie_file = create_storage_chart
      
      # Generate Report
      report_file = generate_report
      
      # Generate E-Mail
      elm_file = generate_email storage_pie_file, report_file
    
      # Send Report
      send_report elm_file
	  
      puts "Finished."
    end
	
    private
    def download_log_files
      exclude_list = @db.get_column(ServerHealth::DBManager::LogFile, :file_name) # get in here the files that are allready in the database
      
      credential_keys = ["ssh_user", "ssh_pw", "ssh_server"]
      credentials = ServerHealth::Credentials.read_from_yaml(File.join(options.config_dir,options.credential_file), credential_keys)
      
      log_downloader = ServerHealth::LogDownloader.new(credentials[:ssh_server],credentials[:ssh_user],credentials[:ssh_pw])
      return log_downloader.download_new_logs(@options.remote_log_dir, @options.local_log_dir, exclude_list)
  	end
    def import_log_files(file_list)
      health_data = ServerHealth::HealthData.new()
      file_list.sort.each do |file|
      log_file = nil
      timestamp = ""
      begin
        timestamp = Helper::HelperClass.timestamp_from_filename(file).to_s
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
    def create_storage_chart
      current_health_state = ServerHealth::DBManager::HealthState.find(:last)
      hd_space_used = current_health_state.hd_space_used
      hd_space_left = current_health_state.hd_space_left
      c = ServerHealth::StoragePie.new(hd_space_used,hd_space_left)
      storage_pie_url = c.get_url
      cd = ServerHealth::ChartDownloader.new(@options.reports_dir,"storage-")
      return cd.download_chart(storage_pie_url)
    end
    def generate_report(storage_pie_file)
      current_health_state = ServerHealth::DBManager::HealthState.find(:last)
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
        :storage_pie_path => File.join(@options.reports_dir, storage_pie_file)
      }
      report = ServerHealth::Report.new(template_file, values_reported)
      report_file = Time.now.strftime("%Y-%m-%d-report.html")
      report.generate(File.join(@options.reports_dir,report_file))
      
      return report_file
    end
    def generate_email(storage_pie_file, report_file)
      images = [File.join(@options.reports_dir,storage_pie_file)]
      email = ServerHealth::EMail.new(images)
      email.import_html(File.join(@options.reports_dir,report_file))
      elm_file = Time.now.strftime("%Y-%m-%d-report.elm")
      email.create_elm(File.join(@options.email_dir,elm_file))
      
      return elm_file
    end
    def send_report(elm_file)
      credential_keys = ["smtp_user", "smtp_pw", "smtp_server", "smtp_port", "smtp_host", "email_from", "email_to"]
      credentials = ServerHealth::Credentials.read_from_yaml(File.join(@options.config_dir,@options.credential_file),credential_keys)
      email_sender = ServerHealth::MailSender.new(File.join(@options.email_dir,elm_file), credentials)
      subject = "Server Health Report vom #{Time.now.strftime("%d. %m. %Y")}"
      email_envelop = "From: #{credentials[:email_from]}\nTo: #{credentials[:email_to]}\nSubject: #{subject}\n"
      email_sender.mail_text = email_envelop + email_sender.mail_text
      email_sender.send_report(credentials[:email_from], [credentials[:email_to]])
    end
  end
end