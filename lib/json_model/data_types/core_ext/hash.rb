class Hash
  def self.json_load(value)
    value.nil? || value.empty? ? nil : value
  end
  
  def self.json_dump(value)
 	value
  end
end