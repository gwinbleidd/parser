require 'yaml'

class Dictionary

  def get_config(dict_name)
    @get_config ||= YAML.load(File.read file_path(dict_name))
  end

  def get_records(dict_name)
    @records = Hash.new

    config = get_config(dict_name)

    config['dictionaries'].each do |dictionary_key, dictionary_value|
      @records[dictionary_key.to_s] = Hash.new

      filename = File.open('../dictionaries/' + dictionary_key.to_s + '.' + dictionary_value['format'].to_s)
      delimiter = dictionary_value['delimiter'].to_i.chr(dictionary_value['encoding'].to_s)

      filename_utf8 = Array.new
      filename.each do |record|
        filename_utf8.push record.to_s.encode('UTF-8', dictionary_value['encoding'].to_s)
      end

      index = 0

      filename_utf8.each do |line|
        index += 1
        @records[dictionary_key.to_s][index] = split_line(line, delimiter.encode('UTF-8'), dictionary_value['fields'])
      end
    end

    @records
  end

  def split_line(line, delimiter, fields_names)
    @split_line = Hash.new

    index = 0

    line.to_s.split(delimiter).each do |arr|
      index += 1
      @split_line[fields_names["column" + index.to_s]['name']] = arr
    end

    @split_line
  end

  private
    def file_path(dict_name)
      "../conf/#{dict_name}/config.yml"
    end
end