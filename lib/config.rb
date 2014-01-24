require 'rubygems'
require 'active_record'
require 'yaml'
require 'dictionaries'
require 'digest/md5'

module Dictionary
  class Config
    attr_reader :config, :output_config, :name, :primary_keys, :key_columns, :foreign_keys, :table

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

      @config||= YAML.load(File.read input_path(dict_name))

      validate @config

      @config['name']= dict_name

      @name = dict_name

      @primary_keys = get_primary_keys(@name)
      @key_columns = get_key_columns(@name)
      @foreign_keys = get_foreign_keys(@name)

      @output_config = get_output_config(dict_name)

      @table = get_table
    end

    private
    def get_table
      unless @config.nil?
        @get_table = Hash.new

        @config['dictionaries'].each { |key, value|
          table = Hash.new
          table[:dictionary] = @name.to_s.downcase
          table[:main] = value['main'] if value.has_key?('main')
          table[:fields] = Hash.new
          table[:fields] = value['fields']

          if @primary_keys.has_key?(key)
            table[:pk] = Hash.new
            table[:pk] = @primary_keys[key][:pk].to_s
          end

          if @foreign_keys.has_key?(key)
            unless table.has_key?(:fk)
              table[:fk] = Hash.new
            end

            @foreign_keys[key].each { |k, v|
              table[:fk][k] = Hash.new
              table[:fk][k][:column] = v[:column].to_s
              table[:fk][k][:table] = @name.to_s.downcase + '_' + v[:table].to_s.downcase
              table[:fk][k][:column_ref] = v[:column_ref].to_s
              table[:fk][k][:return] = v[:return].to_s
            }
          end

          if @key_columns.has_key?(key)
            unless table.has_key?(:ak)
              table[:ak] = Hash.new
            end

            @key_columns[key].each { |k, v|
              table[:ak][k] = v
            }
          end

          @get_table[(@name.to_s.downcase + '_' + key.to_s.downcase).to_sym] = table
        }

        @get_table
      end
    end


    def get_output_config(dict_name)
      @get_output_config||= YAML.load(File.read output_path(dict_name))
    end

    def get_foreign_keys(dict_name)
      if @name.nil?
        @name= dict_name
      end

      if @config.nil?
        @config= get_config(@name)
      end

      @config['dictionaries'].each { |key, value|
        i = 0

        value['fields'].each { |k, v|
          unless v['fk'].nil?
            if @get_foreign_keys.nil?
              @get_foreign_keys = Hash.new
            end

            if @get_foreign_keys[key].nil?
              @get_foreign_keys[key] = Hash.new
            end

            i += 1

            if @get_foreign_keys[key][('fk' + i.to_s).to_sym] == nil
              @get_foreign_keys[key][('fk' + i.to_s).to_sym] = Hash.new
            end
            @get_foreign_keys[key][('fk' + i.to_s).to_sym][:column] = v['name'].to_sym
            @get_foreign_keys[key][('fk' + i.to_s).to_sym][:table] = v['fk']['table'].to_sym
            @get_foreign_keys[key][('fk' + i.to_s).to_sym][:column_ref] = v['fk']['column'].to_sym
            @get_foreign_keys[key][('fk' + i.to_s).to_sym][:return] = v['fk']['return'].to_sym
          end
        }
      }

      @get_foreign_keys
    end

    def get_primary_keys(dict_name)
      if @name.nil?
        @name = dict_name
      end

      if @config.nil?
        @config= get_config(@name)
      end

      @config['dictionaries'].each { |key, value|
        value['fields'].each { |k, v|
          if v['pk']
            if @get_primary_keys == nil
              @get_primary_keys = Hash.new
            end

            if @get_primary_keys[key] == nil
              @get_primary_keys[key] = Hash.new
            end

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
      if @name.nil?
        @name= dict_name
      end

      if @config.nil?
        @config= get_config(@name)
      end

      @get_key_columns = Hash.new

      @config['dictionaries'].each { |key, value|
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

    def config=(m)
      @config = m
    end

    def output_config=(m)
      @output_config = m
    end

    def name=(m)
      @name = m
    end

    def primary_keys=(m)
      @primary_keys = m
    end

    def key_columns=(m)
      @key_columns = m
    end

    def foreign_keys=(m)
      @foreign_keys = m
    end

    def table=(m)
      @table = m
    end

    def validate(config)
      #TODO: method for validating config
      config
    end
  end
end