#!/usr/bin/env ruby
require 'optparse'
module ServerHealth
  class Options
<<<<<<< HEAD
    DATABASE_DIR = "db"
    DATABASE_FILE = "health-logs.sqlite"   
    CONFIG_DIR = "config"
    CREDENTIAL_FILE = "credentials.yml"
    REMOTE_LOG_DIR = "/var/log/health"
    LOCAL_LOG_DIR = "downloads"
    
    attr_reader :database_dir
    attr_reader :database_file
    attr_reader :config_dir
    attr_reader :credential_file
    attr_reader :remote_log_dir
    attr_reader :local_log_dir
    
    def initialize(argv)
      @database_dir = DATABASE_DIR
      @database_file = DATABASE_FILE
      @config_dir = CONFIG_DIR
      @credential_file = CREDENTIAL_FILE
      @remote_log_dir = REMOTE_LOG_DIR
      @local_log_dir = LOCAL_LOG_DIR
      
=======
    def initialize(argv)
>>>>>>> 80a65d3b7aad3d7d3276bbe095b1e84163de46d9
      parse(argv)
    end
    private
    def parse(argv)
      OptionParser.new do |opts|
        opts.banner = "Usage: server_health [ options ]"
<<<<<<< HEAD
        opts.on("-d", "--db-dir path", String, "Path to directory") do |db|
          @database_dir = db
        end
        opts.on("-f", "--db-file name", String, "File name") do |f|
          @database_file = f
        end
        opts.on("-c", "--config-dir path", String, "Path to directory") do |c|
          @config_dir = c
        end
        opts.on("-a", "--credential-file name", String, "File name") do |a|
          @credential_file = a
        end
        opts.on("-r", "--remote-log-dir path", String, "Path to directory") do |r|
          @remote_log_dir = r
        end
        opts.on("-l", "--local-log-dir path", String, "Path to directory") do |l|
          @local_log_dir = l
        end
=======
>>>>>>> 80a65d3b7aad3d7d3276bbe095b1e84163de46d9
        opts.on("-h", "--help", "Show this message") do
          puts opts
          exit
        end
        begin
          # argv = ["-h"] if argv.empty?
          opts.parse!(argv)
        rescue OptionParser::ParseError => e
          STDERR.puts e.message, "\n", opts
          exit(-1)
        end        
      end
    end
  end
end
