module SCParser
  class OutputData
    def initialize
      @log = ParserLogger.instance
    end

    def output(config, records, header)
      output = Hash.new
      records.each do |id, data|
        output[id] = Hash.new
        config['fields'].each_value do |column_desc|
          if column_desc.has_key?('const')
            output[id][column_desc['name']] = column_desc['const']
          end

          if column_desc.has_key?('header')
            if column_desc.has_key?('replace')
              column_desc['replace'].each do |k, v|
                if header[column_desc['header'].to_sym].to_s == v.to_s
                  output[id][column_desc['name']] = k.to_s
                end
              end
            else
              output[id][column_desc['name']] = header[column_desc['header'].to_sym]
            end
          end

          case column_desc['from'].class.to_s
            when 'String'
              if column_desc.has_key?('replace')
                column_desc['replace'].each do |k, v|
                  if data[column_desc['from'].to_sym].to_s == k.to_s
                    output[id][column_desc['name']] = v.to_s
                  end
                end
              else
                output[id][column_desc['name']] = data[column_desc['from'].to_sym] unless column_desc['from'] == 'id'
              end
            when 'Array'
              tmp = Hash[(0...column_desc['from'].size).zip column_desc['from']]
              str = ''
              tmp.each do |k, v|
                if k != column_desc['from'].index(column_desc['from'].last)
                  str << data[v.to_sym].to_s + column_desc['delimiter']
                else
                  str << data[v.to_sym].to_s
                end
              end

              output[id][column_desc['name']] = str
            when 'NilClass'
              if column_desc.has_key?('const')
                output[id][column_desc['name']] = column_desc['const']
              else
                @log.abort 'Unknown field type in output config with NilClass'
              end
            else
              @log.fatal "#{column_desc['from'].class.to_s} - #{column_desc['from']}"
              @log.abort 'Unknown field type in output config'
          end if column_desc.has_key?('from')
        end
      end

      output
    end
  end
end