require '../app/dictionary'
require 'yaml'

dict = Dictionary.new

#puts dict.get_config('fryazinovo')['dictionaries']['abonent']

dict.get_records('fryazinovo')['street'].each  do |k,v|
  v.each do |key, value|
    puts "#{k}, #{key}, #{value}"
  end
end

#puts dict.get_records('fryazinovo')['city'][1]

#yml = File.new('../records.yml', 'w+')
#
#yml.puts dict.get_records('fryazinovo').to_yaml

