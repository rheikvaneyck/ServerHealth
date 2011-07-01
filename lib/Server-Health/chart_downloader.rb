#!/usr/bin/env ruby
require 'net/http'

module ServerHealth
  class ChartDownloader
    attr_accessor :download_path
    
    @chart_server = "chart.apis.google.com"
    
    def initialize(download_path = "../downloads")
      @download_path = download_path
    end
    
    def download_chart(url, file_name)
      Net::HTTP.start(@chart_server) do |http|
        resp = http.get(url)
        if resp.message == "OK"
          open(File.join(@download_path, file_name), "wb") do |file|
            file.write(resp.body)
          end
          return true
        else
          return false
        end
      end
    end

#    private

    def file_name(str="")
       return (str + Time.now.strftime("%Y-%m-%d-%H-%M.png"))
    end
  end
end
