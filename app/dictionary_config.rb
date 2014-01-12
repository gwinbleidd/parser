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
      dict_record.config_md5 = Digest::MD5.file(file_path(dict_name)).hexdigest.to_s
      dict_record.save
    elsif dict_record.config_md5 != Digest::MD5.file(file_path(dict_name)).hexdigest.to_s
      dict_record.name = dict_name
      dict_record.config = File.read file_path(dict_name)
      dict_record.config_md5 = Digest::MD5.file(file_path(dict_name)).hexdigest.to_s
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

  def get_primary_keys(dict_name)
    if self.name == nil
      self.name= dict_name
    end

    if self.config == nil
      self.config= get_config(self.name)
    end

    @get_primary_keys = Hash.new

    self.config['dictionaries'].each { |key, value|
      @get_primary_keys[key] = Hash.new

      value['fields'].each { |k, v|
        if v['pk']
          if @get_primary_keys[key]['pk'.to_sym] != nil
            raise ('More than one primary key for table')
          end
          @get_primary_keys[key]['pk'.to_sym] = v['name'].to_sym
        end
      }
    }

    @get_primary_keys
  end

  def get_key_columns(dict_name)
    if self.name == nil
      self.name= dict_name
    end

    if self.config == nil
      self.config= get_config(self.name)
    end

    @get_key_columns = Hash.new

    self.config['dictionaries'].each { |key, value|
      @get_key_columns[key] = Hash.new

      value['fields'].each { |k, v|
        if v['key'] != nil
          if @get_key_columns[key][v['key'].to_sym] == nil
            @get_key_columns[key][v['key'].to_sym] = Hash.new
          end
          @get_key_columns[key][v['key'].to_sym][v['name'].to_sym] = ''
        end
      }
    }

    @get_key_columns
  end

  def get_records(dict_name)
    @get_records = Hash.new

    if self.name == nil
      self.name= dict_name
    end
    if self.config == nil
      self.config= get_config(self.name)
    end

    config['dictionaries'].each do |dictionary_key, dictionary_value|
      @get_records[dictionary_key.to_s] = Hash.new

      if dictionary_value['format'] == 'txt'
        filename = File.open('../dictionaries/' + dict_name + '/' + dictionary_key.to_s + '.txt')
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