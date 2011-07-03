#!/usr/bin/env ruby
require 'socket'

module ServerHealth
  Content = Struct.new(:marker, :content_id, :file_name, :encoded_body)

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
      return "=-" + Array.new(len/2) { rand(256) }.pack('C*').unpack('H*').first
    end
    
    def gen_content_id
      cid = sprintf("%i.serverhealth@%s", Time.now.to_i, Socket.gethostname)
      return Time.now.to_i
    end
    
    def gen_mime_content(file_name, file_path)
      bin_file = File.read(File.join(file_path,filename))
      encoded_body = [bin_file].pack("m")   # base64
      marker = gen_marker
      content_id = gen_content_id
      mime_content =<<EOF
--#{marker}
Content-ID: <"#{content_id}">
Content-Type: image/png; name=\"#{file_name}\"
Content-Transfer-Encoding:base64
Content-Disposition: attachment; filename="#{file_name}"

#{encoded_body}

--#{marker}--
EOF
      content = Content.new(marker,content_id, file_name, mime_content)
      return content
    end
  end
end
