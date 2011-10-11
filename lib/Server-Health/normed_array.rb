#!/usr/bin/env ruby
require 'date'

module ServerHealth
  class NormedArray
    attr_reader :max_value, :min_value
    alias :max :max_value
    alias :min :min_value

    @max_value = nil
    @min_value = nil
    @normed_array = []
    
    def initialize(data)
      if data.kind_of? Array
        @max_value = data.max
        @min_value = data.min
        @normed_array = data
      elsif data.kind_of? Numeric
        @normed_array << if data < 0 then
          0
        elsif data > 100 then
          100
        else
          data
        end
        @max_value = data
        @min_value = data
      end
    end
    def get_normed_data(from_value = 0, to_value = @max_value)
      
      from_value = [from_value,@min_value].min
      to_value = [to_value,@max_value].max
      
      if @min_value < 0 then
        value_range = @max_value - @min_value
        @normed_array.collect {|i| ((i+@min_value.abs).to_f/value_range)*100 }
      else
        value_range = to_value - from_value
        @normed_array.collect {|i| ((i-from_value).to_f/value_range)*100 }
      end
    end
  end
  
  class NormedDateArray
    attr_accessor :dates
    
    def initialize(dates = [])
      @dates = dates
    end
    def get_normed_dates
      unless @dates.empty?
        first_date = Date.parse(@dates.first.to_s)
        @dates.collect!{|d| (Date.parse(d.to_s) - first_date).to_i}
        @normed_dates = NormedArray.new(@dates)
        return @normed_dates.get_normed_data
      end
    end
  end  
end
