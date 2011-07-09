#!/usr/bin/env ruby
require 'socket'

module ServerHealth
  Content = Struct.new(:marker, :content_id, :file_name, :encoded_body)

  class EMail
    attr_accessor :images
    
    def initialize(images, html_report = "")
      @html_report = File.read(html_report) if File.exists? html_report
      @images = images
    end
    
    def import_html(html_report = "")
      @html_report = File.read(html_report) if File.exists? html_report
      return !@html_report.nil?
    end
    
    def create_elm(elm_file)
      marker = gen_marker
      marker_alternative = gen_marker
      content_structs = gen_mime_content(marker)
      encoded_files = ""
      content_structs.each do |cs|
        set_cid!(cs[:file_name], cs[:content_id])
        encoded_files << cs[:encoded_body] + "\n"
      end
      multipart_email =<<EOF
MIME-Version: 1.0
Content-Type: multipart/related; type="multipart/alternative"; boundary="#{marker}"


--#{marker}
Content-Type: multipart/alternative; boundary="#{marker_alternative}"


--#{marker_alternative}
Content-Type: text/plain
Content-Transfer-Encoding: 8bit

Server Health Report
--#{marker_alternative}
Content-Type: text/html; charset="utf-8"
Content-Transfer-Encoding: 8bit
#{@html_report}
--#{marker_alternative}--
#{encoded_files}
EOF
      File.open(elm_file,"w") do |elm|
        elm.write multipart_email
      end
      return multipart_email.length
    end
    
    #private
    
    def gen_marker(len = 20)
      return "=-" + Array.new(len/2) { rand(256) }.pack('C*').unpack('H*').first
    end
    
    def gen_content_id
      cid = sprintf("%i.serverhealth@%s", Time.now.to_i, Socket.gethostname)
      return cid
    end
    
    def gen_mime_content(marker)
      content_structs = []
      @images.each do |img|
        bin_file = File.read(img)
        encoded_body = [bin_file].pack("m")   # base64
        content_id = gen_content_id
        mime_content =<<EOF
--#{marker}
Content-ID: <#{content_id}>
Content-Type: image/png; name=\"#{File.basename(img)}\"
Content-Transfer-Encoding:base64
Content-Disposition: attachment; filename="#{File.basename(img)}"

#{encoded_body}

--#{marker}--
EOF
        content_structs << Content.new(marker,content_id, File.basename(img), mime_content)
      end
      return content_structs
    end
    
    def set_cid!(file_name, content_id)
      regexp = "/([/]*[.\w\s])*#{file_name}/"
      str = %{		    <IMG SRC="../downloads/chart-2011-07-01-20-49.png" ALIGN="bottom" BORDER="0" ALT="Storage Pie" style="border: solid 2px #bbb;width 250px;height: 250px;margin: 10px;"> }
      str.sub!(/[\/.\-\w\s]*#{file_name}/, "cid:#{content_id}")
      @html_report.sub!(/[\/.\-\w\s]*#{file_name}/, "cid:#{content_id}") unless @html_report.nil?
      return str
    end
  end
end
