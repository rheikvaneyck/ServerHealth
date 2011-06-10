require 'sqlite3'

module ServerHealth
  class DBConnector
    
    def initialize(db_name)
      @db = SQLite3::Database.new(db_name)
      @db.execute( "pragma foreign_keys = on")
    end
    
    def encoding()
      return @db.encoding
    end
    
    def test_db_scheme(db_table_names = [])
      missing_tables = []
      db_tables = @db.execute( "select name from sqlite_master where type='table'")
      db_table_names.each do |t|
        missing_tables << t unless (db_tables.include?([t]))
      end
      puts %{Missing tables: #{missing_tables.join(", ")} } if $DEBUG
      return missing_tables
    end
    
    def create_table(table_hash)
      # tabel_hash = { :name => "table_name", :prim => true, :cols => { :col_name_1 => "TYPE OPTIONS", :col_name_2 => "TYPE [OPTIONS]" ... } }
      cols = []     
      cmd = %{CREATE TABLE #{table_hash[:name]} ( }
      cols << %{id INTEGER PRIMARY KEY} if table_hash[:prim]
      table_hash[:cols].keys.each do |c|
        cols << %{#{c} #{table_hash[:cols][c.to_sym]}}
      end
      cmd = cmd + cols.join(",") + ")"
      puts %{Command: "#{cmd}"} if $DEBUG
      @db.execute(cmd)
      return true
    end
    
    def insert_data(data_hash)
      # data_hash = { :table => "table_name", :cols => { :col_name_1 => "VALUE", :col_name_2 => "VALUE" ... } }
      cols = []     
      cmd = %{INSERT INTO #{data_hash[:table]} }
      data_hash[:cols].keys.each do |c|
        cols << %{#{c}}
      end
      cmd = cmd + "(" + cols.join(",") + ")"
      cmd = cmd + " VALUES "
      cols = []     
      data_hash[:cols].keys.each do |c|
        cols << %{'#{data_hash[:cols][c.to_sym]}'}
      end
      cmd = cmd + "(" + cols.join(",") + ")"
      puts %{Command: "#{cmd}"} if $DEBUG
      @db.execute(cmd)
    end
    
    def get_rows(table, values = [], condition = "")
      # table = "TABLE_NAME" or "TABLE_A AS a JOIN TABLE_B AS b"
      # values = ["col_name_1", "col_name_2",..., "col_name_n"]
      # condition = "col_name = value" or "a.id = b.id" for the JOIN example above
      if values.empty? then
        values_str = "*"
      else
        values_str = values.join(",")
      end
      cmd = %{SELECT #{values_str} FROM #{table}}
      cmd = cmd + %{ WHERE #{condition}} unless condition == ""
      puts %{Command: "#{cmd}"} if $DEBUG
      # return matching rows as array
      return @db.execute(cmd)      
    end
  end
end
