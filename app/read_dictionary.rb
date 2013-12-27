require '../app/dictionary'

dict = Dictionary.new

#puts dict.get_config('fryazinovo')

dict.get_records('fryazinovo').each  do |k,v|
  v.each do |key, value|
    puts "#{k}, #{key}, #{value.to_s.encode('UTF-8')}"
  end
end