module Dictionary
  class Output
    def initialize(config, records)
      output = Hash.new

      records.each do |key, data|
        output=Hash.new
        @name = config.name

        output[:data] = Hash.new

        data.each do |id, rdata|
          output[:data][id] = Hash.new

          config.output_config['fields'].each do |cid, cdesc|
            case cdesc['from'].class.to_s
              when 'String' then
                output[:data][id][cdesc['name']] = rdata[cdesc['from'].to_sym] unless cdesc['from'] == 'id'
              when 'Array'
                puts output[:data][id]
                tmp = Hash[(0...cdesc['from'].size).zip cdesc['from']]
                str = ''
                tmp.each do |k, v|
                  if k != cdesc['from'].index(cdesc['from'].last)
                    str << rdata[v.to_sym] + cdesc['delimiter']
                  else
                    str << rdata[v.to_sym]
                  end
                end

                output[:data][id][cdesc['name']] = str
              when 'NilClass'
                if cdesc.has_key?('const')
                  output[:data][id][cdesc['name']] = cdesc['const']
                else
                  raise "Unknown field type with NilClass"
                end
              else
                puts "#{cdesc['from'].class.to_s} - #{cdesc['from']}"
                raise "Unknown class"
            end

          end
        end
      end

      @records = output
    end
  end
end