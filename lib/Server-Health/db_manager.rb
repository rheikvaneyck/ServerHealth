# This module encapsulates functionality related to the connection to the 
# database. 
#--
# Copyright (c) 2011 Marcus Nasarek
# Licensed under GPL. No warranty is provided.

require 'active_record'

module ServerHealth
  # Class of the Database Manager
  # 
  # :call-seq:
  #    DB.new(database_name)
  class DBManager
    def initialize(db_file_path)
      ActiveRecord::Base.establish_connection(
        :adapter => "sqlite3",
        :database => db_file_path
      )
      create_tables
    end
    class LogFile < ActiveRecord::Base
      has_one :health_state
    end
    class HealthState < ActiveRecord::Base
      belongs_to :log_file
    end

    def connection_state?
      return ActiveRecord::Base.connected?
    end
    
    def table_exists?(table_name)
      return ActiveRecord::Base.connection.table_exists?(table_name)
    end
    
    def insert_record(model, values)
      model.create(values)
    end
    
    def get_column(model, column)
      model.find(:all, :select => column.to_s).map(&column)
    end
    
    private
    def create_tables
      unless ActiveRecord::Base.connection.table_exists?("log_files")
        ActiveRecord::Schema.define do
          create_table :log_files do |table|
            table.column :file_name, :string
            table.column :file_date, :date
          end
        end
      end
      unless ActiveRecord::Base.connection.table_exists?("health_states")
        ActiveRecord::Schema.define do
          create_table :health_states do |table|
            table.column :log_file_id, :integer
            table.column :raid_state, :string, :default => "-"
            table.column :hd1_error_state, :string, :default => "-"
            table.column :hd2_error_state, :string, :default => "-"
            table.column :hd1_Raw_Read_Error_Rate, :string, :default => "-"
            table.column :hd2_Raw_Read_Error_Rate, :string, :default => "-"
            table.column :hd1_Reallocated_Sector_Ct, :string, :default => "-"
            table.column :hd2_Reallocated_Sector_Ct, :string, :default => "-"
            table.column :hd1_Offline_Uncorrectable, :string, :default => "-"
            table.column :hd2_Offline_Uncorrectable, :string, :default => "-"
            table.column :hd1_Reallocated_Event_Count, :string, :default => "-"
            table.column :hd2_Reallocated_Event_Count, :string, :default => "-"
            table.column :hd1_run_time, :integer, :default => "0"
            table.column :hd2_run_time, :integer, :default => "0"
            table.column :hd_space_used, :integer, :default => "0"
            table.column :hd_space_left, :integer, :default => "0"
          end
        end
      end 
    end
    
  end 
end

