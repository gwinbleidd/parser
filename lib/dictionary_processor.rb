require 'dbf'

module SCParser
  class DictionaryProcessor
    attr :config

    def initialize(params)
      @log = SCParser::ParserLogger.instance

      @config = SCParser::DictionaryConfig.new(params[:name])

      @properties = {
          name:          params[:name],
          files:         params[:files],
          input_files:   @config.properties[:input_files],
          side_files:    @config.properties[:side_files],
          header:        @config.properties[:header],
          main_file:     @config.properties[:main_file],
          foreign_keys:  @config.properties[:foreign_keys],
          output_config: @config.properties[:output_config],
          table:         @config.properties[:table]
      }
    end

    def process_files
      @properties[:files].each do |file|
        @log.abort "Input files not exist for #{@properties[:name]}, file #{file}" unless input_files_exists?(file)
        process_main_file(file)
      end
    end

    def input_files_exists?(filename)
      result = Hash.new

      @properties[:input_files].each { |file|
        result[file] = File.exists?(File.join(SCParser::Application.tmp_path, @properties[:name], File.basename(filename).gsub('.', '_'), file))
      }

      !result.has_value?(false)
    end

    def process_main_file(incoming_file)
      file_desc = @properties[:main_file].values[0]

      if file_desc['format'] == 'txt'
        tf = SCParser::TextFile.new(properties: @properties, file: incoming_file)
        tf.process_main_file
      elsif file_desc['format'] == 'dbf'
        df = SCParser::DBaseFile.new(properties: @properties, file: incoming_file)
        df.process_main_file
      else
        @log.abort 'Unknown format'
      end
    end
  end
end