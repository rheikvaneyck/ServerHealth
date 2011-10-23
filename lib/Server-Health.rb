$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'helper_class'
require 'Server-Health/options'
require 'Server-Health/credentials'
require 'Server-Health/log_downloader'
require 'Server-Health/health_file_parser'
require 'Server-Health/db_manager'
require 'Server-Health/normed_array'
require 'Server-Health/generate_charts'
require 'Server-Health/generate_report'
require 'Server-Health/generate_email'
require 'Server-Health/send_report'
require 'Server-Health/runner'

module ServerHealth
  VERSION = '0.1.0'
end