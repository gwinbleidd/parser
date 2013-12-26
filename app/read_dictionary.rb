require '../app/dictionary'

dict_866 = File.open('../dictionaries/street.txt')
dict_utf8 = Array.new

dict_866.each do |record|
  dict_utf8.push record.to_s.encode('UTF-8', 'cp866')
end

dict = Dictionary.new

dict.get_records(dict_utf8, 179.chr('cp866').encode('UTF-8')).each  do |k,v|
  v.each do |key, value|
    puts "#{k}, #{key}, #{value.to_s.encode('UTF-8')}"
  end
end