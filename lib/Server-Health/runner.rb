#!/usr/bin/env ruby
require_relative 'options'
require_relative 'credentials'
require_relative 'log_downloader'
require_relative 'health_file_parser'
require_relative 'db_connector'

module ServerHealth
  class Runner
    
    def initialize(argv)
      @options = Options.new(argv)
      @db = ServerHealth::DBConnector.new(File.join(@options.database_dir, @options.database_file))
    end
    
    def run
      create_missing_tables
      cobj = ServerHealth::Credentials.new()
      credentials = cobj.read_from_yaml(File.join(@options.config_dir,@options.credential_file),["ssh_user", "ssh_pw", "ssh_server"])
      
      #log_downloader = ServerHealth::LogDownloader.new(credentials[:ssh_server],credentials[:ssh_user],credentials[:ssh_pw])
      exclude_list = @db.get_rows("log_files", ["file_name"]) # get in here the files that are allready in the database
      #log_downloader.download_new_logs(@options.remote_log_dir, @options.local_log_dir, exclude_list)
      
      health_data = ServerHealth::HealthData.new()
      
      puts "Finished."
    end
    
    private
    def create_missing_tables
      puts "db encoding: #{@db.encoding}"
      @db.test_db_scheme(["log_files", "health_status"]).each do |t|
        case t
        when "log_files"
          table_hash = { :name => "log_files", :prim => true, :cols => {
              :file_name => "TEXT UNIQUE",
              :file_date => "DATE" } }
          @db.create_table(table_hash)
        when "health_status"
          table_hash = { :name => "health_status", :prim => true, :cols => {
              :file_id => "INTEGER NOT NULL",
              :raid_state => "TEXT",
              :hd1_error_state => "TEXT",
              :hd2_error_state => "TEXT",
              :hd1_Raw_Read_Error_Rate => "TEXT",
              :hd2_Raw_Read_Error_Rate => "TEXT",
              :hd1_Reallocated_Sector_Ct => "TEXT",
              :hd2_Reallocated_Sector_Ct => "TEXT",
              :hd1_Offline_Uncorrectable => "TEXT",
              :hd2_Offline_Uncorrectable => "TEXT",
              :hd1_Reallocated_Event_Count => "TEXT",
              :hd2_Reallocated_Event_Count => "TEXT",
              :hd1_run_time => "LONG",
              :hd2_run_time => "LONG",
              :hd_space_used => "LONG",
              :hd_space_left => "LONG" },
              :constraint => "log_files_file_id_fk FOREIGN KEY (file_id) REFERENCES log_files (id)" }
          @db.create_table(table_hash)
        end
      end
    end
  end
end
