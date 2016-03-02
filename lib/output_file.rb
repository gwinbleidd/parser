module SCParser
  class OutputFile
    def initialize(params)
      @log = ParserLogger.instance
      @name = params[:name]
      @config = SCParser::DictionaryConfig.new(params[:name])
      @log.info("Starting create OutputFile for #{@name}")
      @properties = {
          name: params[:name],
          output_config: @config.properties[:output_config],
          table: @config.properties[:table]
      }

      dt = SCParser::DictionaryTable.new(name: @properties[:table][:name])
      @tbl = dt.object

      if @properties[:output_config]['file'].has_key?('name') and @properties[:output_config]['file'].has_key?('type')
        @output_file = File.expand_path "../output/#{@properties[:output_config]['file']['name']}.#{@properties[:output_config]['file']['type']}"
      else
        @log.abort "No output file defined for #{@name}"
      end

      if @properties[:output_config]['file'].has_key?('name')
        @sep = @properties[:output_config]['file']['delimiter']
      else
        @log.abort "No separator defined for #{@name}"
      end

      @properties[:rows_count] = @tbl.count

      @properties[:size] = SCParser::Application.size(@properties[:rows_count])

      @log.abort "No rows in table for #{@name}" if @properties[:rows_count] == 0
    end

    def process
      File.open(@output_file, "w") do |csv|
        i = 0

        @tbl.find_in_batches(batch_size: @properties[:size]) do |records|
          records.each do |rec|
            record = Hash.new
            @properties[:output_config]['fields'].each_value { |value|
              if value['from'] == 'id'
                record[value['name'].to_sym] = eval('rec.' + value['from'].to_s).to_i.to_s
              else
                if value.has_key?('type')
                  record[value['name'].to_sym] = eval('rec.' + value['name'].to_s).to_i.to_s if value['type'] == 'number'
                  record[value['name'].to_sym] = eval('rec.' + value['name'].to_s).to_s if value['type'] == 'string'
                  record[value['name'].to_sym] = eval('rec.' + value['name'].to_s).to_f.to_s if value['type'] == 'currency'
                  record[value['name'].to_sym] = eval('rec.' + value['name'].to_s).to_f.to_s if value['type'] == 'float'
                else
                  record[value['name'].to_sym] = eval('rec.' + value['name'].to_s).to_s.strip.encode(@properties[:output_config]['file']['encoding'])
                end
              end
            }
            if i == 0
              csv.puts header(record)
              csv.puts to_csv record
            else
              csv.puts to_csv record
            end

            i+=1
            if i == @properties[:rows_count]
              @log.info("#{@name}: Derived #{i} of #{@properties[:rows_count]} records")
            else
              print "Derived #{i} of #{@properties[:rows_count]} records\r" if i % @properties[:size] == 0 or i == 1
            end
          end
        end
      end
    end

    private
    def header(hash)
      hash.keys.join @sep unless hash.nil?
    end

    def to_csv(hash)
      hash.values.map do |value|
        value.gsub(@sep, "") unless value.nil?
      end.join @sep
    end
  end
end