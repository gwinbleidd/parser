require 'yaml'

class Dictionary

  def get_config(dict_name)
    @get_config ||= YAML.load(File.read file_path(dict_name))
  end

  def is_record(line, delimiter, fields)
    splitted_line = split_line(line, delimiter)

    if splitted_line.size == fields.size
      @is_record = Hash.new

      splitted_line.each { |line_key, line_value|
        @is_record[fields[line_key]['name']] = line_value
      }
    else
      puts "Line \"#{line}\" don't correspond to config"
      exit
    end

    @is_record
  end

  def get_records(dict_name)
    @get_records = Hash.new

    config = get_config(dict_name)

    config['dictionaries'].each do |dictionary_key, dictionary_value|
      @get_records[dictionary_key.to_s] = Hash.new

      if dictionary_value['format'] == 'txt'
        filename = File.open('../dictionaries/' + dict_name + '/' + dictionary_key.to_s + '.' + dictionary_value['format'].to_s)
        delimiter = dictionary_value['delimiter'].to_i.chr(dictionary_value['encoding'].to_s)

       index = 0

        filename.each { |line|
          index += 1
          line = line.to_s.encode('UTF-8', dictionary_value['encoding'].to_s).delete("\n")
          @get_records[dictionary_key.to_s][index] = is_record(line, delimiter.encode('UTF-8'), dictionary_value['fields'])
        }
      end
    end

    @get_records
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

  private
  def file_path(dict_name)
    "../conf/#{dict_name}/config.yml"
  end
end