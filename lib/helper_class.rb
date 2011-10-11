module Helper
  class HelperClass   
    def self.timestamp_from_filename(filename)
      if /(\d{4})-(\d{2})-(\d{2})/ =~ filename
        return Time.local($1,$2,$3,6,0)
      else
        return nil
      end
    end
    def self.reduce_array(array, to_length)
      return array if array.length < to_length
      reduced_array = []
      l = (array.length / to_length)
      to_length.times do |t|
        index = ((t)*l).to_i
        reduced_array << array.reverse[index]
      end
      return reduced_array.reverse
    end
  end
end

