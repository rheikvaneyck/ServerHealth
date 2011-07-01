#!/usr/bin/env ruby
require 'erb'

module ServerHealth
  class Report
    def initialize(template_file, values_to_be_reported_hash)
      template = File.read(template_file)
    end
    def generate
      @hml_file = ERB.new(template)
      @report = @html_file.result      
    end
  end
end
