dictionary = File.new('../dictionaries/street.txt')

records = Hash.new

index = 0

dictionary.each do |line|
  index += 1
  records[index] = Hash.new

  index1 = 0

  line.to_s.split(179.chr('cp866')).each do |arr|
    index1 += 1
    records[index]["column" + index1.to_s] = arr.to_s.encode('UTF-8')
  end

  records.each  do |k,v|
    v.each do |key, value|
      puts "#{k}, #{key}, #{value}"
    end
  end
end