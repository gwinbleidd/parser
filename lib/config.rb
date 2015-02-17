require 'rubygems'
require 'active_record'
require 'yaml'
require 'dictionaries'
require 'digest/md5'

module Dictionary
  class Configuration
    attr_reader :config, :output_config, :name, :primary_keys, :key_columns, :foreign_keys, :table

    def initialize(dict_name)
      Dictionary.logger.info("Starting create Config for #{dict_name}")
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

      @primary_keys = get_primary_keys
      @key_columns = get_key_columns
      @foreign_keys = get_foreign_keys

      @output_config = get_output_config(dict_name)

      @table = get_table
    end

    private
    def get_table
      get_table = Hash.new

      config = self.config
      table = Hash.new
      table[:dictionary] = self.name.to_s.downcase
      table[:fields] = Hash.new

      @output_config['fields'].each { |key, value|
        if value['from'] != 'id'
          table[:fields][key] = Hash.new
          case value['from'].class.to_s
            when 'String'
              config['dictionaries'].each { |dname, ddesc|
                ddesc['fields'].each { |cname, cdesc|
                  if cdesc['name'] == value['from']
                    table[:fields][key] = cdesc.clone
                    if cdesc.has_key?('pk')
                      raise "More than 1 pk defined for table #{self.name}" unless table[:pk].nil?
                      table[:pk] = Hash.new
                      table[:pk][:name] = value['name']
                      table[:pk][:type] = cdesc['type']
                    end

                    if cdesc.has_key?('key') and ddesc.has_key?('main')
                      table[:keys] = Array.new if table[:keys].nil?
                      key_column = Hash.new
                      key_column[:name] = value['name']
                      key_column[:type] = cdesc['type']
                      table[:keys].append key_column
                    end
                  end
                }
              }
              table[:fields][key]['name'] = value['name']
              table[:fields][key]['type'] = value['type'] if value.has_key?('type')
              table[:fields][key]['type'] = 'string' if value.has_key?('replace')
            when 'Array'
              table[:fields][key]['name'] = value['name']
              table[:fields][key]['type'] = 'string'
            else
              if value.has_key?('const')
                table[:fields][key]['name'] = value['name']
                table[:fields][key]['type'] = 'string'
              end
          end
        end
      }

      get_table[self.name.to_s.downcase.to_sym] = table

      get_table
    end


    def get_output_config(dict_name)
      output_config||= YAML.load(File.read output_path(dict_name))
    end

    def get_foreign_keys
      config = self.config

      foreign_keys = Hash.new

      config['dictionaries'].each { |key, value|
        i = 0

        value['fields'].each { |k, v|
          unless v['fk'].nil?
            if foreign_keys[key].nil?
              foreign_keys[key] = Hash.new
            end

            i += 1
            if foreign_keys[key][('fk' + i.to_s).to_sym] == nil
              foreign_keys[key][('fk' + i.to_s).to_sym] = Hash.new
            end
            foreign_keys[key][('fk' + i.to_s).to_sym][:column] = v['name'].to_sym
            foreign_keys[key][('fk' + i.to_s).to_sym][:table] = v['fk']['table'].to_sym
            foreign_keys[key][('fk' + i.to_s).to_sym][:column_ref] = v['fk']['column'].to_sym
            foreign_keys[key][('fk' + i.to_s).to_sym][:return] = v['fk']['return'].to_sym
          end
        }
      }

      foreign_keys
    end

    def get_primary_keys
      config = self.config

      primary_keys = Hash.new

      config['dictionaries'].each { |key, value|
        value['fields'].each { |k, v|
          if v['pk']
            if primary_keys[key].nil?
              primary_keys[key] = Hash.new
            else
              raise ('More than one primary key for table')
            end

            primary_keys[key][:name] = v['name'].to_sym
            primary_keys[key][:type] = v['type']
          end
        }
      }

      primary_keys
    end

    def get_key_columns
      config = self.config

      key_columns = Hash.new

      config['dictionaries'].each { |key, value|
        key_columns[key] = Hash.new

        value['fields'].each { |k, v|
          if v['key'] != nil
            if key_columns[key][v['key'].to_sym] == nil
              key_columns[key][v['key'].to_sym] = Array.new
            end
            key_columns[key][v['key'].to_sym].push v['name'].to_sym
          end
        }
      }

      key_columns
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