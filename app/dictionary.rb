class Dictionary

  def get_records(filename)
    @records = Hash.new

    @dictionary = File.new(filename)

    index = 0

    @dictionary.each do |line|
      index += 1
      @records[index] = line.to_s.encode('UTF-8')
    end

    @dictionary.close

    @records
  end

  def split_line(line, delimiter)
    @split_line = Hash.new

    line_a = line.to_s.split(delimiter)

    line_a.each do |column|

    end
  end
end