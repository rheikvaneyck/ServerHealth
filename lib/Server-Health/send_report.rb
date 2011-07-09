#!/usr/bin/env ruby
require 'net/smtp'

module ServerHealth
  class MailSender
    attr_accessor :mail_text, :smtp_server, :smtp_port, :smtp_host, :smtp_user, :smtp_pw
    
    def initialize(elm_file, credentials)
      @mail_text = File.read(elm_file) if File.exists? elm_file
      @smtp_server = credentials[:smtp_server]
      @smtp_port = credentials[:smtp_port]
      @smtp_host = credentials[:smtp_host]
      @smtp_user = credentials[:smtp_user]
      @smtp_pw = credentials[:smtp_pw]    
    end
    
    def send_report(from, to)
      # Let's put our code in safe area
      begin 
        Net::SMTP.start(@smtp_server,@smtp_port,@smtp_host,@smtp_user,@smtp_pw) do |smtp|
          smtp.send_message @mail_text, from, to
        end
        str = "message from #{from} to #{to.join(" ")} sent"
      rescue Exception => e  
        print "Exception occured: " + e.to_s
        str = "message from #{from} to #{to.join(" ")} not sent"
      end
      return str
    end
  end
end
