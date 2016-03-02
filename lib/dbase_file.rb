require 'general_file'

module SCParser
  class DBaseFile < SCParser::GeneralFile
    def process_main_file
      @log.info "Processing main Dbase file for #{@properties[:name]}"
      file_name, file_desc = @properties[:main_file].first
      dictionary_file = "#{file_name}.#{file_desc['format']}"
      index = 0
      main_file = File.join(SCParser::Application.properties[:tmp_path], @properties[:name], File.basename(@file).gsub('.', '_'), dictionary_file)
      dbf = DBF::Table.new(main_file, nil, file_desc['encoding'].to_s)
      @rows_processed[:size] = dbf.record_count
      size = SCParser::Application.size(@rows_processed[:size])
      od = SCParser::OutputData.new
      du = SCParser::DictionaryUploader.new(file_size: size, table: @properties[:table], name: @properties[:name])

      dbf.each_slice(size) do |lines|
        records = Hash.new

        lines.each do |line|
          records[index] = Hash.new if records[index].nil?
          line.attributes.each do |attribute_name, attribute_value|
            records[index][attribute_name.to_s.downcase.to_sym] = attribute_value.to_s.encode('UTF-8', file_desc['encoding'])
          end
          print "Processed #{index} of #{@rows_processed[:size]} records\r" if index % size == 0 or index == 1
          index += 1
        end

        uploaded = du.process od.output(@properties[:output_config], records, nil)
        @rows_processed[:processed] = uploaded[:processed]
        @rows_processed[:inserted] = uploaded[:inserted]
        @rows_processed[:updated] = uploaded[:updated]
      end

      @log.info "Processed #{@rows_processed[:processed]} of #{@rows_processed[:size]}, inserted #{@rows_processed[:inserted]}, updated #{@rows_processed[:updated]}"
      @log.info "Main DBase file processed for #{@properties[:name]}"
    end
  end
end