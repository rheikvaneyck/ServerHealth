#!/usr/bin/env ruby
require 'net/http'

module ServerHealth
  class ChartDownloader
    attr_accessor :download_path, :file_prefix
        
    def initialize(download_path = "../downloads", file_prefix = "")
      @chart_server = "chart.apis.google.com"
      @download_path = download_path
      @file_prefix = file_prefix
    end
    
    def download_chart(url, filename = "")
      if filename.empty? then
        filename = file_name
      end
      puts url if $DEBUG
      puts filename if $DEBUG 
      puts @chart_server if $DEBUG
      Net::HTTP.start(@chart_server) do |http|
        resp = http.get(url)
        if resp.message == "OK"
          open(File.join(@download_path, filename), "wb") do |file|
            file.write(resp.body)
          end
          return filename
        else
          return nil
        end
      end
    end

#    private

    def file_name()
       return (@file_prefix + Time.now.strftime("%Y-%m-%d-%H-%M.png"))
    end
  end
end
