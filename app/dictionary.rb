class Dictionary

  def get_records(filename, delimiter)
    @records = Hash.new

    index = 0

    filename.each do |line|
      index += 1
      @records[index] = split_line(line, delimiter)
    end

    @records
  end

  def split_line(line, delimiter)
    @split_line = Hash.new

    index = 0

    line.to_s.split(delimiter).each do |arr|
      index += 1
      @split_line["column" + index.to_s] = arr
    end

    @split_line
  end
end