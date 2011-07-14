#!/usr/bin/env ruby
require 'optparse'
module ServerHealth
  class Options
    def initialize(argv)
      parse(argv)
    end
    private
    def parse(argv)
      OptionParser.new do |opts|
        opts.banner = "Usage: server_health [ options ]"
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
