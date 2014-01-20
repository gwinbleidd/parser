module Dictionary
  class Record
    attr_accessor :records, :name

    def initialize(config)
      self.records = Hash.new

      config['dictionaries'].each do |dictionary_key, dictionary_value|
        self.records[dictionary_key.to_s.to_sym] = Hash.new

        dict_name = config['name']

        if dictionary_value['format'] == 'txt'
          filename = File.open('../dictionaries/' + dict_name + '/' + dictionary_key.to_s + '.txt')
          delimiter = dictionary_value['delimiter'].to_i.chr(dictionary_value['encoding'].to_s)

          index = 0

          filename.each { |line|
            index += 1
            line = line.to_s.encode('UTF-8', dictionary_value['encoding'].to_s).delete("\n")
            self.records[dictionary_key.to_s.to_sym][index] = is_record(line, delimiter.encode('UTF-8'), dictionary_value['fields'])
          }
        end
      end
    end

    private
    def is_record(line, delimiter, fields)
      splitted_line = split_line(line, delimiter)

      if splitted_line.size == fields.size
        @is_record = Hash.new

        splitted_line.each { |line_key, line_value|
          @is_record[fields[line_key]['name'].to_s.to_sym] = line_value
        }
      else
        puts "Line \"#{line}\" don't correspond to config"
        exit
      end

      @is_record
    end

    def split_line(line, delimiter)
      @split_line = Hash.new

      index = 0

      line.to_s.split(delimiter).each { |arr|
        index += 1
        @split_line["column" + index.to_s] = arr
      }

      @split_line
    end
  end
end