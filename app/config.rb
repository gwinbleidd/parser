require 'rubygems'
require 'active_record'
require 'yaml'
require 'dictionaries'
require 'digest/md5'
require 'dictionary'

module Dictionary
  class Config
    attr_accessor :config, :output_config, :name, :primary_keys, :key_columns, :foreign_keys

    def initialize(dict_name)
      dict_record = Dictionaries.find_by(:name => dict_name)
      if dict_record == nil
        dict_record = Dictionaries.new
        dict_record.name = dict_name
        dict_record.config = File.read input_path(dict_name)
        dict_record.config_md5 = Digest::MD5.file(input_path(dict_name)).hexdigest.to_s
        dict_record.save
      elsif dict_record.config_md5 != Digest::MD5.file(input_path(dict_name)).hexdigest.to_s
        dict_record.name = dict_name
        dict_record.config = File.read input_path(dict_name)
        dict_record.config_md5 = Digest::MD5.file(input_path(dict_name)).hexdigest.to_s
        dict_record.save
      end

      self.config||= YAML.load(File.read input_path(dict_name))
      self.config['name']= dict_name

      self.name = dict_name

      self.primary_keys = get_primary_keys(self.name)
      self.key_columns = get_key_columns(self.name)
      self.foreign_keys = get_foreign_keys(self.name)

      self.output_config = get_output_config(dict_name)
    end

    private
    def get_output_config(dict_name)
      @get_output_config||= YAML.load(File.read output_path(dict_name))
    end

    def get_foreign_keys(dict_name)
      if self.name == nil
        self.name= dict_name
      end

      if self.config == nil
        self.config= get_config(self.name)
      end

      self.config['dictionaries'].each { |key, value|
        i = 0

        value['fields'].each { |k, v|
          if v['fk'] != nil
            if @get_foreign_keys == nil
              @get_foreign_keys = Hash.new
            end

            if @get_foreign_keys[key] == nil
              @get_foreign_keys[key] = Hash.new
            end

            i += 1

            if @get_foreign_keys[key][('fk' + i.to_s).to_sym] == nil
              @get_foreign_keys[key][('fk' + i.to_s).to_sym] = Hash.new
            end
            @get_foreign_keys[key][('fk' + i.to_s).to_sym][:table] = v['fk']['table'].to_sym
            @get_foreign_keys[key][('fk' + i.to_s).to_sym][:column] = v['fk']['column'].to_sym
          end
        }
      }

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
              @get_key_columns[key][v['key'].to_sym] = Array.new
            end
            @get_key_columns[key][v['key'].to_sym].push v['name'].to_sym
          end
        }
      }

      @get_key_columns
    end

    def input_path(dict_name)
      "../config/#{dict_name}/input.yml"
    end

    def output_path(dict_name)
      "../config/#{dict_name}/output.yml"
    end
  end
end