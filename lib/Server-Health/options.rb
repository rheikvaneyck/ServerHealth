#!/usr/bin/env ruby
require 'optparse'

module ServerHealth
  class Options
    BASE_DIR = "server"
    DATABASE_DIR = "db"
    DATABASE_FILE = "logs-dev.sqlite"   
    CONFIG_DIR = "config"
    CREDENTIAL_FILE = "credentials.yml"
    REMOTE_LOG_DIR = "/var/log/health"
    LOCAL_LOG_DIR = "downloads"
    REPORT_DIR = "reports"
    TEMPLATE_DIR = "template"
    REPORT_TEMPLATE = "report_template.html.erb"
    EMAIL_DIR = "mails"
    
    attr_reader :base_dir
    attr_reader :database_dir
    attr_reader :database_file
    attr_reader :config_dir
    attr_reader :credential_file
    attr_reader :remote_log_dir
    attr_reader :local_log_dir
    attr_reader :report_dir
    attr_reader :template_dir
    attr_reader :report_template
    attr_reader :email_dir
    
    def initialize(argv)
      @base_dir = BASE_DIR
      @database_dir = DATABASE_DIR
      @database_file = DATABASE_FILE
      @config_dir = CONFIG_DIR
      @credential_file = CREDENTIAL_FILE
      @remote_log_dir = REMOTE_LOG_DIR
      @local_log_dir = LOCAL_LOG_DIR
      @report_dir = REPORT_DIR
      @template_dir = TEMPLATE_DIR
      @report_template = REPORT_TEMPLATE
      @email_dir = EMAIL_DIR
      
      parse(argv)
      puts argv
    end
    private
    def parse(argv)
      OptionParser.new do |opts|
        opts.banner = "Usage: server_health [ options ]"
        opts.on("-b", "--base-dir path", String, "Path to directory") do |b|
          @base_dir = b
        end
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
        opts.on("-p", "--report-dir path", String, "Path to directory") do |p|
          @report_dir = p
        end
        opts.on("-d", "--template-dir path", String, "Path to directory") do |d|
          @template_dir = d
        end
        opts.on("-t", "--report-template file", String, "Path to directory") do |t|
          @report_template = t
        end
        opts.on("-e", "--email-dir path", String, "Path to directory") do |e|
          @email_dir = e
        end
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