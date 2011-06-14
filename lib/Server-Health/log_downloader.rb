# This module encapsulates functionality related to the downloads of log files
# from a remote server over ssh and scp.
#--
# Copyright (c) 2011 Marcus Nasarek
# Licensed under GPL. No warranty is provided.

require 'net/ssh'
require 'net/scp'

module ServerHealth
  # Class of the Downloader
  #
  # :call-seq:
  #    LogDownloader.new(server, username, password)
  class LogDownloader
    
    attr_reader :files, :downloads
    
    def initialize(srv, user, pw)
      @servername = srv
      @username = user
      @pw = pw
    end
    
    # Gets the remote server name
    #
    # :call-seq:
    #    LogDownloader.get_remote_hostname()   -> string 
    def get_remote_hostname()
      hostname = nil
      Net::SSH.start(@servername, @username, :password => @pw) do |ssh|
        hostname = ssh.exec!("hostname")
      end
      return hostname
    end
    
    # Gets the logs from a specific directory of the remote server and
    # copies them to a local directory
    #
    # :call-seq:
    #    LogDownloader.download_new_logs(remote_dir, local_dir, exclude_list)   -> array
    #
    # An optional array with filenames that should be excluded can be given.
    # The methods combines other methods from this class and returns an array
    # with the downloaded filenames. 
    def download_new_logs(remote_dir, local_dir, exclude_list = [])
      file_list = []
      long_file_list = ""
      long_file_list = get_remote_log_list(remote_dir)
      import_file_list(file_list, long_file_list) unless long_file_list == ""
      kick_existing_items(file_list, exclude_list) unless file_list.empty?
      download_logs(remote_dir, local_dir, file_list) unless file_list.empty?
      return file_list
    end
    
    def download_logs(remote_dir, local_dir, file_list)
      unless file_list.empty?
        downloads = []
         Net::SCP.start(@servername, @username, :password => @pw) do |scp|
          file_list.each do |f|
            downloads << scp.download!(File.join(remote_dir,f),File.join(local_dir,f))
          end
         end       
      end
      return downloads.length
    end
    
    def get_remote_log_list(remote_dir)
      long_file_list = ""
      Net::SSH.start(@servername, @username, :password => @pw) do |ssh|
        puts %{connected to #{ssh.exec!("hostname")} } if $DEBUG
        long_file_list = ssh.exec!("ls -ltr #{remote_dir}")
      end
      return long_file_list
    end
        
    def kick_existing_items(new_list, old_list)
      new_list.delete_if {|item| old_list.include?(item)}
      return (old_list.length - new_list.length)
    end
    
    def import_file_list(file_list, long_file_list)
      long_file_list.each_line do |line|
          a = line.split
          # puts %{file_date: #{a[5]} #{a[6]}, file_name: #{a[7]} }
          next if a.length < 8
          # [ filename, "file_date file_time"]
          file_list << a[7]
      end
      return file_list.length
    end
  end
end