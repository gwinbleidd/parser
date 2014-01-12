require 'rubygems'
require 'active_record'
require 'yaml'
require './models/dictionary'
require 'digest/md5'

class DictionaryConfig
  attr_accessor :config, :name

  def get_config(dict_name)
    dict_record = Dictionary.find_by(:name => dict_name)
    if dict_record == nil
      dict_record = Dictionary.new
      dict_record.name = dict_name
      dict_record.config = File.read file_path(dict_name)
      dict_record.config_md5 = Digest::MD5.file(file_path(dict_name)).hexdigest
      dict_record.save
    end
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

    self.name= dict_name
    self.config= get_config(self.name)

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
    "../config/#{dict_name}/config.yml"
  end
end