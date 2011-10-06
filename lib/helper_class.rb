module Helper
  class HelperClass   
    def self.timestamp_from_filename(filename)
      if /(\d{4})-(\d{2})-(\d{2})/ =~ filename
        return Time.local($1,$2,$3,6,0)
      else
        return nil
      end
    end
  end
end

