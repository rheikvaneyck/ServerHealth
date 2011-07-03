#!/usr/bin/env ruby
require 'socket'

module ServerHealth
  class EMail
    attr_accessor :from, :to, :subject
    
    def initialize(email_envelop, html_report = "", images)
      @from = email_envelop[:from]
      @to = email_envelop[:to]
      @subject = email_envelop[:subject]
      
      @html_report = File.read(html_report) if File.exists? html_report
      @images = images
    end
    
    def import_html(html_report = "")
      @html_report = File.read(html_report) if File.exists? html_report
      return !@html_report.nil?
    end
    
    def create_eml(elm_file, elm_dir = "../mails")
      
    end
    
    #private
    
    def gen_marker(len = 20)
      return Array.new(len/2) { rand(256) }.pack('C*').unpack('H*').first
    end
    
    def gen_content_id
      cid = sprintf("%i.serverhealth@%s", Time.now.to_i, Socket.gethostname)
      return Time.now.to_i
    end
  end
end
