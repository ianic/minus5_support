require 'active_support/core_ext'

class Hash

  def deep_symbolize_keys!
    self.symbolize_keys!
    self.each_value do |value|
      value.deep_symbolize_keys! if value.kind_of?(Hash) || value.kind_of?(Array)      
    end
  end

end

class Array

  def deep_symbolize_keys!
    self.each do |value|
      value.deep_symbolize_keys! if value.kind_of?(Hash) || value.kind_of?(Array)
    end
  end
  
end
