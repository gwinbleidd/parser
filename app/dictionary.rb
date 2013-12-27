require 'yaml'

class Dictionary

  def get_config(dict_name)
    @get_config ||= YAML.load(File.read file_path(dict_name))
  end

  def to_regexp(fields, delimiter)
    @to_regexp = '^'.to_s

    fields_re = Array.new

    fields.each { |field_key, field_value|
      case field_value['type']
        when 'string'  then fields_re[field_key.to_s.delete('column').to_i - 1] = '\w'
        when 'number' then fields_re[field_key.to_s.delete('column').to_i - 1] = '\d'
        else
          1 == 1
      end

      if field_value['length'].to_s.empty?
        fields_re[field_key.to_s.delete('column').to_i - 1] << '+'
      else
        fields_re[field_key.to_s.delete('column').to_i - 1] << '{' + field_value['length'].to_s + '}'
      end
    }

    fields_re.each { |re|
      @to_regexp << re
      @to_regexp << '\\' + delimiter.to_s
    }

    @to_regexp[-1] = '$'

    @to_regexp
  end

  def get_records(dict_name)
    @get_records = Hash.new

    config = get_config(dict_name)

    config['dictionaries'].each do |dictionary_key, dictionary_value|
      @get_records[dictionary_key.to_s] = Hash.new

      if dictionary_value['format'] == 'txt'
        filename = File.open('../dictionaries/' + dictionary_key.to_s + '.' + dictionary_value['format'].to_s)
        delimiter = dictionary_value['delimiter'].to_i.chr(dictionary_value['encoding'].to_s)

        filename_utf8 = Array.new
        filename.each { |record|
          filename_utf8.push record.to_s.encode('UTF-8', dictionary_value['encoding'].to_s).delete("\n")
        }

        index = 0

        filename_utf8.each { |line|
          index += 1
          @get_records[dictionary_key.to_s][index] = split_line(line, delimiter.encode('UTF-8'), dictionary_value['fields'])
        }
      end
    end

    @get_records
  end

  def split_line(line, delimiter, fields_names)
    @split_line = Hash.new

    index = 0

    line.to_s.split(delimiter).each { |arr|
      index += 1
      @split_line[fields_names["column" + index.to_s]['name']] = arr
    }

    @split_line
  end

  private
    def file_path(dict_name)
      "../conf/#{dict_name}/config.yml"
    end
end