module ServerHealth
  class HealthData
    
    attr_reader :raid_state, :hd1_error_state, :hd2_error_state, :hd1_Raw_Read_Error_Rate, :hd2_Raw_Read_Error_Rate, :hd1_Reallocated_Sector_Ct, :hd2_Reallocated_Sector_Ct, :hd1_Offline_Uncorrectable, :hd2_Offline_Uncorrectable, :hd1_Reallocated_Event_Count, :hd2_Reallocated_Event_Count, :hd1_run_time, :hd2_run_time, :hd_space_used, :hd_space_left
    
    def initialize  
      @error_test_line = 0
      @raid_state, @hd1_error_state, @hd2_error_state, @hd1_Raw_Read_Error_Rate, @hd2_Raw_Read_Error_Rate, @hd1_Reallocated_Sector_Ct, @hd2_Reallocated_Sector_Ct, @hd1_Offline_Uncorrectable, @hd2_Offline_Uncorrectable, @hd1_Reallocated_Event_Count, @hd2_Reallocated_Event_Count, @hd1_run_time, @hd2_run_time, @hd_space_used, @hd_space_left = "", "", "", "", "", "", "", "", "", "", "", 0, 0, 0, 0
    end
    
    def parse_health_file(file)
      foundFirstHD = false
      
      File.foreach(file) do |line|
        if line =~ /RAID/
          puts "RAID:" if $DEBUG
        end
        puts line.scan(/name\s+:\s\w+/) if $DEBUG
        puts line.scan(/type\s+:\s\w+/) if $DEBUG
        if line =~ /status\s+:\s\w+/
          puts line if $DEBUG
          @raid_state = line.split(/\s+/)[2]
        end
        if line =~ /storage/
          puts "STORAGE:" if $DEBUG
        end
        if line =~ /%\s+\/$/
          storage_a = line.split(/\s+/)
          puts %{Benutzt: #{storage_a[2]}, Frei: #{storage_a[3]} } if $DEBUG
          @hd_space_used, @hd_space_left = storage_a[2], storage_a[3]
        end
        if line =~ /S.M.A.R.T.T./
          puts "S.M.A.R.T.T.:" if $DEBUG
        end
        puts line.scan(/Device Model:[\s\w-]+/) if $DEBUG
        puts line.scan(/Serial Number:[\s\w-]+/) if $DEBUG
        if line =~ /Raw_Read_Error_Rate/
          test_a = line.gsub(/^\s+/,"").split(/\s+/)
          (puts %{HD1 Raw_Read_Error_Rate = #{test_a[9]}} unless foundFirstHD == true) if $DEBUG
          @hd1_Raw_Read_Error_Rate = test_a[9] unless foundFirstHD == true
          (puts %{HD2 Raw_Read_Error_Rate = #{test_a[9]}} if foundFirstHD == true) if $DEBUG
          @hd2_Raw_Read_Error_Rate = test_a[9] if foundFirstHD == true        
        end
        if line =~ /Reallocated_Sector_Ct/
          test_a = line.gsub(/^\s+/,"").split(/\s+/)
          (puts %{HD1 Reallocated_Sector_Ct = #{test_a[9]}} unless foundFirstHD == true) if $DEBUG
          @hd1_Reallocated_Sector_Ct = test_a[9] unless foundFirstHD == true
          (puts %{HD2 Reallocated_Sector_Ct = #{test_a[9]}} if foundFirstHD == true) if $DEBUG
          @hd2_Reallocated_Sector_Ct = test_a[9] if foundFirstHD == true        
        end
        if line =~ /Offline_Uncorrectable/
          test_a = line.gsub(/^\s+/,"").split(/\s+/)
          (puts %{HD1Offline_Uncorrectable = #{test_a[9]}} unless foundFirstHD == true) if $DEBUG
          @hd1_Offline_Uncorrectable = test_a[9] unless foundFirstHD == true
          (puts %{HD2 Offline_Uncorrectable = #{test_a[9]}} if foundFirstHD == true) if $DEBUG
          @hd2_Offline_Uncorrectable = test_a[9] if foundFirstHD == true        
        end
        if line =~ /Reallocated_Event_Count/
          test_a = line.gsub(/^\s+/,"").split(/\s+/)
          (puts %{HD1 Reallocated_Event_Count = #{test_a[9]}} unless foundFirstHD == true) if $DEBUG
          @hd1_Reallocated_Event_Count = test_a[9] unless foundFirstHD == true
          (puts %{HD2 Reallocated_Event_Count = #{test_a[9]}} if foundFirstHD == true) if $DEBUG
          @hd2_Reallocated_Event_Count = test_a[9] if foundFirstHD == true        
        end
        if line =~ /SMART Error Log Version/
          foundFirstHD = true
        end
        if line =~ /#\s+1\s+Short offline/
          @error_test_line += 1
          test_a = line.gsub(/^#\s+1\s+/,"").split(/\s{2,}/)
          (puts %{#{test_a[1]}, Power_On_Hours: #{sprintf("%6i h",test_a[3])}} unless (@error_test_line<3)) if $DEBUG
          @hd1_error_state, @hd1_run_time = test_a[1], test_a[3] if @error_test_line == 3
          @hd2_error_state, @hd2_run_time = test_a[1],test_a[3] if @error_test_line == 4      
        end
      end
      return true
    end
  end
end
