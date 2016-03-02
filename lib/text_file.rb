require 'general_file'
require 'dictionary_uploader'

module SCParser
  class TextFile < SCParser::GeneralFile
    def side_files_records
      result = Hash.new

      @properties[:side_files].each do |file_name, file_desc|
        records = Hash.new
        dictionary_file = "#{file_name}.#{file_desc['format']}"
        side_file = File.join(SCParser::Application.properties[:tmp_path], @properties[:name], File.basename(@file).gsub('.', '_'), dictionary_file)
        delimiter = file_desc['delimiter'].to_i.chr(file_desc['encoding'].to_s).encode('UTF-8')
        start = file_desc.has_key?('startfrom') ? file_desc['startfrom'] : 1
        @log.debug " Processing side text file #{dictionary_file} for #{@properties[:name]}"
        File.foreach(side_file).drop(start - 1).each_with_index do |line, line_index|
          begin
            splitted_line = line.to_s.encode('UTF-8', file_desc['encoding'].to_s).split(delimiter)
            if splitted_line.size != file_desc['fields'].size
              @log.abort "Row #{index}: Line \"#{line}\" don't correspond to config, columns in row #{splitted_line.size}, columns in config #{fields.size}"
            end

            records[splitted_line[file_desc['pk_column_id']]] = Hash.new if records[splitted_line[file_desc['pk_column_id']]].nil?

            splitted_line.each_with_index do |field, field_index|
              unless field_index == file_desc['pk_column_id']
                field_name = file_desc['fields']["column#{field_index + 1}"]['name']
                field_type = file_desc['fields']["column#{field_index + 1}"]['type']

                case field_type
                  when 'integer'
                    field = field.to_s.strip.to_i
                  else
                    field = field.to_s.strip
                end

                records[splitted_line[file_desc['pk_column_id']]][field_name] = field
              end
            end
          rescue Exception => e
            @log.fatal "Error in line #{line_index}"
            @log.fatal e
            @log.abort e.backtrace.join "\n"
          end
        end

        result[file_name] = records
      end

      result
    end

    def header_records
      unless @properties[:header].nil?
        header_name, header_desc = @properties[:header].first
        result = Hash.new
        dictionary_file = "#{header_name}.#{header_desc[:format]}"
        main_file = File.join(SCParser::Application.properties[:tmp_path], @properties[:name], File.basename(@file).gsub('.', '_'), dictionary_file)
        File.foreach(main_file).first(header_desc[:fields].size).each do |line|
          line = line.to_s.encode('UTF-8', header_desc[:encoding].to_s).strip
          regexp = /\#(\w+)\s?([a-zA-Z0-9а-яА-Я .,]*)/
          parameter = line.split(regexp)[1].nil? ? '' : line.split(regexp)[1].strip.downcase.to_sym
          value = line.split(regexp)[2].nil? ? '' : line.split(regexp)[2].strip
          if header_desc[:fields].has_key?(parameter)
            case header_desc[:fields][parameter]
              when 'string'
                result[parameter] = value.to_s
              when 'integer'
                result[parameter] = value.to_i
              when 'float'
                result[parameter] = value.gsub(' ', '').gsub(',', '.').to_f
              else
                @log.abort "Unknown header field data type, field #{parameter}, dictionary #{@properties[:name]}, file #{@file}"
            end
          else
            @log.abort "Unknown header field #{parameter}, dictionary #{@properties[:name]}, file #{@file}"
          end
        end

        result unless result.empty?
      end
    end

    def process_main_file
      file_name, file_desc = @properties[:main_file].first
      dictionary_file = "#{file_name}.#{file_desc['format']}"
      main_file = File.join(SCParser::Application.properties[:tmp_path], @properties[:name], File.basename(@file).gsub('.', '_'), dictionary_file)
      index = 0
      header_data = header_records
      delimiter = file_desc['delimiter'].to_i.chr(file_desc['encoding'].to_s).encode('UTF-8')
      header_rows_count = @properties[:header].nil? ? 0 : @properties[:header].values[0][:fields].size
      @rows_processed[:size] = File.open(main_file, 'r').readlines.count - header_rows_count
      size = SCParser::Application.size(@rows_processed[:size])
      side_file_records = side_files_records unless @properties[:side_files].nil?
      od = SCParser::OutputData.new
      du = SCParser::DictionaryUploader.new(file_size: @rows_processed[:size], table: @properties[:table], name: @properties[:name])

      @log.info "Processing main text file for #{@properties[:name]}"
      File.foreach(main_file).drop(header_rows_count).each_slice(size) do |lines|
        records = Hash.new
        lines.each do |line|
          begin
            records[index] = Hash.new
            splitted_line = line.to_s.encode('UTF-8', file_desc['encoding'].to_s).split(delimiter)
            if splitted_line.size != file_desc['fields'].size
              @log.fatal "Row #{index + size}: Line \"#{line.to_s.encode('UTF-8', file_desc['encoding'].to_s)}\" don't correspond to config, columns in row #{splitted_line.size}, columns in config #{file_desc['fields'].size}"
              @log.abort "Splitted line: #{splitted_line}"
            end

            splitted_line.each_with_index do |field, field_index|
              field_name = file_desc['fields']["column#{field_index + 1}"]['name']
              field_type = file_desc['fields']["column#{field_index + 1}"]['type']

              case field_type
                when 'integer'
                  field = field.to_s.strip.to_i
                else
                  field = field.to_s.strip
              end

              if !@properties[:foreign_keys].nil? && @properties[:foreign_keys][file_name].has_key?(field_name.to_sym)
                foreign_key = @properties[:foreign_keys][file_name][field_name.to_sym]
                records[index][foreign_key[:return]] = side_file_records[foreign_key[:table].to_s][field.to_s].nil? ? '' : side_file_records[foreign_key[:table].to_s][field.to_s][foreign_key[:return].to_s]

              else
                records[index][field_name.to_sym] = field
              end
            end
            print "Processed #{index} of #{@rows_processed[:size]} records\r" if index % size == 0 or index == 1
            index += 1
          rescue => e
            @log.fatal "Error in line #{index + size}"
            @log.fatal e
            @log.abort e.backtrace.join "\n"
          end
        end

        uploaded = du.process od.output(@properties[:output_config], records, header_data)
        @rows_processed[:processed] = uploaded[:processed]
        @rows_processed[:inserted] = uploaded[:inserted]
        @rows_processed[:updated] = uploaded[:updated]
      end

      @log.info "Processed #{@rows_processed[:processed]} of #{@rows_processed[:size]}, inserted #{@rows_processed[:inserted]}, updated #{@rows_processed[:updated]}"
      @log.info "Main text file processed for #{@properties[:name]}"
    rescue => e
      @log.fatal e
      @log.abort e.backtrace.join "\n"
    end
  end
end