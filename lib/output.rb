class Output
  attr_reader :records, :size, :mod

  def initialize(config, records)
    output = Hash.new

    records.each do |key, data|
      @name = config.name

      output[:data] = Hash.new

      data.each do |id, rdata|
        output[:data][id] = Hash.new

        config.output_config['fields'].each do |cid, cdesc|
          if cdesc.has_key?('const')
            output[:data][id][cdesc['name']] = cdesc['const']
          end

          if cdesc.has_key?('from')
            case cdesc['from'].class.to_s
              when 'String' then
                if cdesc.has_key?('replace')
                  cdesc['replace'].each do |k, v|
                    if rdata[cdesc['from'].to_sym].to_s == v.to_s
                      output[:data][id][cdesc['name']] = k.to_s
                    end
                  end
                else
                  output[:data][id][cdesc['name']] = rdata[cdesc['from'].to_sym] unless cdesc['from'] == 'id'
                end
              when 'Array'
                tmp = Hash[(0...cdesc['from'].size).zip cdesc['from']]
                str = ''
                tmp.each do |k, v|
                  if k != cdesc['from'].index(cdesc['from'].last)
                    str << rdata[v.to_sym].to_s + cdesc['delimiter']
                  else
                    str << rdata[v.to_sym].to_s
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
    end

    @records = output
    @size = @records[:data].size

    case @size
      when 0 then
        abort "No data for #{@name}"
      when 1 .. 10 then
        @mod = 1
      when 11 .. 1000 then
        @mod = 5
      when 1001 .. 10000 then
        @mod = 100
      when 10001 .. 50000 then
        @mod = 500
      else
        @mod = 1000
    end
  end
end