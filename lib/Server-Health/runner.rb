#!/usr/bin/env ruby
require 'fileutils'

module ServerHealth
  class Runner
    
    def initialize(argv)
      @options = ServerHealth::Options.new(argv)
      create_directories
      provide_templates
      @db = ServerHealth::DBManager.new(File.join(@options.base_dir,@options.database_dir, @options.database_file))
    end
    
    def run
      # Download Log Files
      file_list = download_log_files
      #puts "Anzahl neuer Log-Dateien: #{file_list.length}"
      # or: initial load if log files already downloaded
      # file_list = get_files_from_local_dir
      # puts file_list.length if $DEBUG
      # Insert the log files and timestamps into the DB
      import_log_files file_list unless file_list.length == 0
      
      # Visualize Data
      # 1. Storage Pie
      storage_pie_file = create_storage_chart
      puts "Diagramm zum Speicherverbrauch: #{storage_pie_file}"
      # 2. Storage over time Diagram
      # storage_time_file = create_storage_over_time_chart
      # puts "Diagramm zum zeitlichen Speicherverbrauch: #{storage_time_file}"
      # Generate Report
      report_file = generate_report(storage_pie_file)
      puts "Statusbericht: #{report_file}"
      
      # Generate E-Mail
      elm_file = generate_email storage_pie_file, report_file
      puts "E-Mail-Datei zum Statusbericht: #{elm_file}"
      # Send Report
      recipients = send_report elm_file
      puts "E-Mail mit Statusbericht an #{recipients} versandt."
    end
	
    private
    def create_directories
      @options.instance_variables.each do |v|
        if  v =~ /^.(?!base|remote).*_dir$/ then
          # puts File.join(@options.base_dir, @options.instance_variable_get(v))
          dir = File.join(@options.base_dir, @options.instance_variable_get(v))
          FileUtils.mkdir_p(dir)
        end
      end
    end
    def provide_templates
      # report template
      gems_dir = system('gem env gemdir')
      gem_template_dir = File.join(gems_dir,"gems","server-health","template",@options.report_template)
      if File.exists?(File.join(@options.template_dir,@options.report_template))
        template_src = File.join(@options.template_dir,@options.report_template)
      elsif File.exists?(gem_template_dir)
        template_src = File.join(gem_template_dir)
      else
        puts "Can not provide report template"
        exit
      end
      template_dest = File.join(@options.base_dir, @options.report_dir,@options.report_template)
      FileUtils.cp(template_src,template_dest) unless File.exists?(template_dest)
      # credential template
      gem_template_dir = File.join(gems_dir,"gems","server-health","config",@options.credential_file)
      if File.exists?(File.join(@options.config_dir,@options.credential_file))
        template_src = File.join(@options.config_dir,@options.credential_file)
      elsif File.exists?(gem_template_dir)
        template_src = File.join(gem_template_dir)
      else
        puts "Can not provide credential sample file"
      end
      template_dest = File.join(@options.base_dir, @options.config_dir,@options.credential_file)
      unless File.exists?(template_dest)
        begin 
          FileUtils.cp(template_src,template_dest)
        ensure
          puts "Edit the credential file #{template_dest}, programm ends here for now"
          exit
        end
      end     
    end
    def get_files_from_local_dir
      file_list = []
      Dir.chdir(@options.base_dir,@options.local_log_dir) do
        file_list = Dir.glob("*.log")
      end
      return file_list
    end  
 
    def download_log_files
      exclude_list = @db.get_column(ServerHealth::DBManager::LogFile, :file_name) # get in here the files that are allready in the database
      
      credential_keys = ["ssh_user", "ssh_pw", "ssh_server"]
      credentials = ServerHealth::Credentials.read_from_yaml(File.join(@options.base_dir,@options.config_dir,@options.credential_file), credential_keys)
      
      log_downloader = ServerHealth::LogDownloader.new(credentials[:ssh_server],credentials[:ssh_user],credentials[:ssh_pw])
      return log_downloader.download_new_logs(@options.remote_log_dir, File.join(@options.base_dir,@options.local_log_dir), exclude_list)
    end
    def import_log_files(file_list)
      file_list.sort.each do |file|
        health_data = ServerHealth::HealthData.new()
        log_file = nil
        timestamp = ""
        begin
          timestamp = Helper::HelperClass.timestamp_from_filename(file).to_s
          health_data.parse_health_file(File.join(@options.base_dir,@options.local_log_dir, file))
          log_file = @db.insert_record(ServerHealth::DBManager::LogFile, {:file_name => file, :file_date => timestamp})
          puts "Log file #{file} imported" if $DEBUG
        rescue
          puts "couldn't process #{file} for import in table 'log_files'"         
        end
        begin
          @db.insert_record(ServerHealth::DBManager::HealthState, {
            :log_file_id => log_file.id,
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
          }) unless log_file.nil?
          puts "Health file #{file} imported" if $DEBUG
        rescue
          puts "couldn't process #{file} for import in table 'health_states"         
        end
      end
    end
    def create_storage_chart
      current_health_state = ServerHealth::DBManager::HealthState.find(:last)
      hd_space_used = current_health_state.hd_space_used
      hd_space_left = current_health_state.hd_space_left
      c = ServerHealth::StoragePie3D.new(hd_space_used,hd_space_left)
      chart_file_name = Time.now.strftime("storage-%Y-%m-%d-%H-%M.png")
      c.save_chart_to_file(File.join(@options.base_dir,@options.report_dir, chart_file_name))
      return chart_file_name
    end
    def create_storage_over_time_chart
      #hd_space_used = []
      #monitor_time = []
      #log_files = ServerHealth::DBManager::LogFile.select("id,file_date")
      #log_files.each do |l|
      #  monitor_time << l.file_date
      #  hd_space_used << (l.health_state.hd_space_used / 1024)
      #end
      #
      #monitor_time = Helper::HelperClass.reduce_array(monitor_time,50)
      #hd_space_used = Helper::HelperClass.reduce_array(hd_space_used,50)
      #x = ServerHealth::NormedDateArray.new(monitor_time).get_normed_dates
      ## FIXME x-data is broken
      #x = (1..100).step(2).to_a
      #y = ServerHealth::NormedArray.new(hd_space_used).get_normed_data
      #
      #y_from_value = 0
      #y_to_value =  ((hd_space_used.max.to_i)/1000 + 1) * 1000
      #y_label_step = (y_to_value - y_from_value)/10.0
      #y_labels = (y_from_value..y_to_value).step(y_label_step).to_a
      #y_labels = y_labels.collect {|i| i.to_i }
      #
      #x_labels = Helper::HelperClass.reduce_array(monitor_time,10)
      #chart = ServerHealth::StorageHistoryChart.new([x,y], y_labels, x_labels)
      #storage_time_url = chart.get_url
      #puts storage_time_url
      #cd = ServerHealth::ChartDownloader.new(File.join(@options.base_dir,@options.report_dir),"storage_time-")
      #return cd.download_chart(storage_time_url)
    end
    def generate_report(storage_pie_file)
      current_health_state = ServerHealth::DBManager::HealthState.find(:last)
      server_name = get_server_name
      template_file = File.join(@options.base_dir,@options.template_dir, @options.report_template)
      values_reported = {
        :server_name => server_name,
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
        :storage_pie_path => storage_pie_file
      }
      report = ServerHealth::Report.new(template_file, values_reported)
      report_file = Time.now.strftime("%Y-%m-%d-report.html")
      report.generate(File.join(@options.base_dir,@options.report_dir,report_file))
      
      return report_file
    end
    def generate_email(storage_pie_file, report_file)
      images = [File.join(@options.base_dir,@options.report_dir,storage_pie_file)]
      email = ServerHealth::EMail.new(images)
      email.import_html(File.join(@options.base_dir,@options.report_dir,report_file))
      elm_file = Time.now.strftime("%Y-%m-%d-report.elm")
      email.create_elm(File.join(@options.base_dir,@options.email_dir,elm_file))
      
      return elm_file
    end
    def send_report(elm_file)
      credential_keys = ["smtp_user", "smtp_pw", "smtp_server", "smtp_port", "smtp_host", "email_from", "email_to"]
      credentials = ServerHealth::Credentials.read_from_yaml(File.join(@options.base_dir,@options.config_dir,@options.credential_file),credential_keys)
      email_sender = ServerHealth::MailSender.new(File.join(@options.base_dir,@options.email_dir,elm_file), credentials)
      subject = "Server Health Report vom #{Time.now.strftime("%d. %m. %Y")}"
      email_envelop = "From: #{credentials[:email_from]}\nTo: #{credentials[:email_to]}\nSubject: #{subject}\n"
      email_sender.mail_text = email_envelop + email_sender.mail_text
      email_sender.send_report(credentials[:email_from], credentials[:email_to].split(","))
      return credentials[:email_to]
    end
    def get_server_name
      credential_keys = ["ssh_server"]
      config_file_path = File.join(@options.base_dir,@options.config_dir,@options.credential_file)
      credentials = ServerHealth::Credentials.read_from_yaml(config_file_path,credential_keys)
      return credentials[:ssh_server]
    end
  end
end