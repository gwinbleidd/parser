require 'rubygems'
require 'active_record'
require 'yaml'
require './models/dictionary'
require 'digest/md5'

class DictionaryConfig
  attr_accessor :config, :name, :primary_keys, :key_columns, :foreign_keys

  def initialize(dict_name)
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

    self.config||= YAML.load(File.read file_path(dict_name))
    self.config['name']= dict_name

    self.name= dict_name

    self.primary_keys= get_primary_keys(self.name)
    self.key_columns= get_key_columns(self.name)
    self.foreign_keys= get_foreign_keys(self.name)
  end

  def get_foreign_keys(dict_name)
    if self.name == nil
      self.name= dict_name
    end

    if self.config == nil
      self.config= get_config(self.name)
    end

    @get_foreign_keys = Hash.new

    self.config['dictionaries'].each { |key, value|
      @get_foreign_keys[key] = Hash.new

      i = 0

      value['fields'].each { |k, v|
        if v['fk'] != nil
          i += 1

          if @get_foreign_keys[key][('fk' + i.to_s).to_sym] == nil
            @get_foreign_keys[key][('fk' + i.to_s).to_sym] = Hash.new
          end
          @get_foreign_keys[key][('fk' + i.to_s).to_sym][:table] = v['fk']['table'].to_sym
          @get_foreign_keys[key][('fk' + i.to_s).to_sym][:column] = v['fk']['column'].to_sym
        end
      }
    }

    #puts @get_foreign_keys

    @get_foreign_keys
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

  private
  def file_path(dict_name)
    "../config/#{dict_name}/config.yml"
  end
end