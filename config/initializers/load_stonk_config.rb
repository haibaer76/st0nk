require 'ostruct'

# creates a new OpenStruct from the given hash
# converts all values which are hashes to OpenStruct recursively
# converts all values which are arrays recursively
def create_ostruct_from_hash(hash)
  ret = OpenStruct.new(hash)
  hash.each do |key, value|
    if value.is_a?(Hash)
      ret.send("#{key}=", create_ostruct_from_hash(value))
    elsif value.is_a?(Array)
      ret.send("#{key}=", create_ostruct_array(value))
    end
  end
  ret
end

# creates an array from the given array
# iterates through all elements
# if the element is a hash, create an OpenStruct
# if the element is an array, call this function recursively
def create_ostruct_array(array)
  ret = []
  array.each do |value|
    if value.is_a?(Hash)
      ret << create_ostruct_from_hash(value)
    elsif value.is_a?(Array)
      ret << create_ostruct_array(value)
    else
      ret << value
    end
  end
  ret
end

attributes = YAML.load_file("#{RAILS_ROOT}/config/stonk.yml")[RAILS_ENV]
STONK_CONFIG = create_ostruct_from_hash(attributes)

