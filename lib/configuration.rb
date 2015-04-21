require 'config_file'
require 'dict_config'

class Configuration < DictConfig
  attr_reader :cf, :name

  def table
    table = Hash.new
    table[:dictionary] = self.name.to_s.downcase
    table[:name] = self.name.to_s.pluralize
    table[:fields] = Hash.new

    output_config['fields'].each { |key, value|
      if value['from'] != 'id'
        table[:fields][key.to_sym] = Hash.new
        case value['from'].class.to_s
          when 'String'
            input_config['dictionaries'].each { |dname, ddesc|
              ddesc['fields'].each { |cname, cdesc|
                if cdesc['name'] == value['from']
                  table[:fields][key.to_sym] = cdesc.clone
                  if cdesc.has_key?('pk')
                    abort "More than 1 pk defined for table #{self.name}" unless table[:pk].nil?
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
        end
      end
    }

    table
  end

  def foreign_keys
    foreign_keys = Hash.new

    input_config['dictionaries'].each { |key, value|
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

    foreign_keys unless foreign_keys.size == 0
  end

  def primary_keys
    primary_keys = Hash.new

    input_config['dictionaries'].each { |key, value|
      value['fields'].each { |k, v|
        if v['pk']
          if primary_keys[key].nil?
            primary_keys[key] = Hash.new
          else
            abort ('More than one primary key for table')
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

    input_config['dictionaries'].each { |key, value|
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

  def header
    header = Hash.new

    input_config['dictionaries'].each { |key, value|
      if value.has_key?('header')
        header[key] = Hash.new
        header[key][:def] = value['header_def_symbol'] if value.has_key?('header_def_symbol')
        header[key][:fields] = Hash.new
        value['header'].each { |column_name, column_def| header[key][:fields][column_name.to_sym] = column_def }
      end
    }

    header
  end
end