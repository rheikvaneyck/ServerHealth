#!/usr/bin/env ruby
require 'yaml'

module ServerHealth
  class Credentials
    
    def initialize()
      @ret_hash = {}
    end
    
    def read_from_yaml(file_name, credential_keys = [])
      data = IO.read(file_name) if File.exists?(file_name)
      props = YAML.load(data)
      credential_keys.each do |c|
        h = { c.to_sym => props[c]}
        @ret_hash.merge!(h)
      end

      return (@ret_hash)
    end
    
  end
end

