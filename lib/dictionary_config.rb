module SCParser
  class DictionaryConfig
    attr_reader :properties

    def initialize(name)
      @log = SCParser::ParserLogger.instance
      @name = name

      @properties = {
          input_config: input_config,
          output_config: output_config
      }

      @properties[:input_files] = input_files
      @properties[:main_file] = main_file
      @properties[:side_files] = side_files
      @properties[:header] = header
      @properties[:table] = table
      @properties[:foreign_keys] = foreign_keys
      @properties[:primary_keys] = primary_keys
      @properties[:key_columns] = key_columns
    end

    def file(type)
      File.expand_path(File.join(SCParser::Application.config_path, @name, "#{type.to_s}.yml"))
    end

    def config(type)
      begin
        YAML.load(File.read file(type))
      rescue => e
        @log.fatal e.message
        @log.abort e.backtrace.join "\n"
      end
    end

    def input_config
      config(:input)
    end

    def output_config
      config(:output)
    end

    def input_files
      result = Array.new

      if @properties[:input_config]['dictionaries'].nil?
        @log.abort "No input file defined for #{@name}"
      else
        @properties[:input_config]['dictionaries'].each do |file_name, file_desc|
          result.append "#{file_name}.#{file_desc['format']}"
        end
      end

      result
    end

    def main_file
      result = Hash.new

      if @properties[:input_config]['dictionaries'].nil?
        @log.abort "No input file defined for #{@name}"
      else
        @properties[:input_config]['dictionaries'].each do |file_name, file_desc|
          result[file_name] = file_desc if file_desc.has_key?('main') & file_desc['main']
        end
      end

      @log.abort "More than one main file defined for  #{@name}" if result.size > 1

      result unless result.empty?
    end

    def side_files
      result = Hash.new

      if @properties[:input_config]['dictionaries'].nil?
        @log.abort "No input file defined for #{@name}"
      else
        @properties[:input_config]['dictionaries'].each do |file_name, file_desc|
          unless file_desc.has_key?('main')
            result[file_name] = file_desc
            file_desc['fields'].each do |field_name, field_desc|
              result[file_name]['pk_column_id'] = field_name.gsub('column', '').to_i - 1 if field_desc['pk']
            end
            @log.abort "Side file #{file_name} has no primary key definition in config" unless result[file_name].has_key?('pk_column_id')
          end
        end
      end

      result unless result.empty?
    end

    def header
      header = Hash.new

      @properties[:input_config]['dictionaries'].each { |key, value|
        if value.has_key?('header') & value.has_key?('main') & value['main']
          header[key] = Hash.new
          header[key][:def] = value['header_def_symbol'] if value.has_key?('header_def_symbol')
          header[key][:format] = value['format']
          header[key][:encoding] = value['encoding']
          header[key][:fields] = Hash.new
          value['header'].each { |column_name, column_def| header[key][:fields][column_name.to_sym] = column_def }
        end
      }

      header unless header.empty?
    end

    def table
      @log = ParserLogger.instance

      table = Hash.new
      table[:dictionary] = @name
      table[:name] = @name.to_s.pluralize
      table[:fields] = Hash.new

      @properties[:output_config]['fields'].each { |key, value|
        if value['from'] != 'id'
          table[:fields][key.to_sym] = Hash.new
          case value['from'].class.to_s
            when 'String'
              @properties[:input_config]['dictionaries'].each_value { |ddesc|
                ddesc['fields'].each_value { |cdesc|
                  if cdesc['name'] == value['from']
                    table[:fields][key.to_sym] = cdesc.clone
                    if cdesc.has_key?('pk')
                      @log.abort "More than 1 pk defined for table #{self.name}" unless table[:pk].nil?
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
              table[:fields][key.to_sym]['name'] = value['name']
              table[:fields][key.to_sym]['type'] = value['type'] if value.has_key?('type')
              table[:fields][key.to_sym]['type'] = 'string' if value.has_key?('replace')
            when 'Array'
              table[:fields][key.to_sym]['name'] = value['name']
              table[:fields][key.to_sym]['type'] = 'string'
            else
              if value.has_key?('const')
                table[:fields][key.to_sym]['name'] = value['name']
                table[:fields][key.to_sym]['type'] = 'string'
              end

              if value.has_key?('header')
                table[:fields][key.to_sym]['name'] = value['name']
                table[:fields][key.to_sym]['type'] = header[main_file.keys[0]][:fields][value['header'].to_sym]
                if value.has_key?('replace')
                  table[:fields][key.to_sym]['type'] = 'string'
                end
              end
          end
        end
      }

      table
    end

    def foreign_keys
      foreign_keys = Hash.new

      @properties[:input_config]['dictionaries'].each { |key, value|
        i = 0

        value['fields'].each { |k, v|
          unless v['fk'].nil?
            if foreign_keys[key].nil?
              foreign_keys[key] = Hash.new
            end

            i += 1
            column = v['name'].to_sym
            if foreign_keys[key][column] == nil
              foreign_keys[key][column] = Hash.new
            end
            foreign_keys[key][column][:table] = v['fk']['table'].to_sym
            foreign_keys[key][column][:column_ref] = v['fk']['column'].to_sym
            foreign_keys[key][column][:return] = v['fk']['return'].to_sym
          end
        }
      }

      foreign_keys unless foreign_keys.size == 0
    end

    def primary_keys
      primary_keys = Hash.new

      @properties[:input_config]['dictionaries'].each { |key, value|
        value['fields'].each { |k, v|
          if v['pk']
            if primary_keys[key].nil?
              primary_keys[key] = Hash.new
            else
              @log.abort ('More than one primary key for table')
            end

            primary_keys[key][:name] = v['name'].to_sym
            primary_keys[key][:type] = v['type']
          end
        }
      }

      primary_keys
    end

    def key_columns
      key_columns = Hash.new

      @properties[:input_config]['dictionaries'].each { |key, value|
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
  end
end