#!/usr/bin/env ruby
require 'yaml'

module ServerHealth
  class Credentials
    attr_reader :username, :password, :server
    
    def initialize(username = "", password = "", server = "")
      @username = username
      @password = password
      @server = server
    end
    
    def read_from_yaml(file_name)
      data = IO.read(file_name) if File.exists?(file_name)
      props = YAML.load(data)
      @username = props["username"]
      @password = props["password"]
      @server = props["server"]
      return (data.nil? ? 0 : data.length)
    end
    
  end
end

