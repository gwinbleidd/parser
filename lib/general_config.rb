module SCParser
  class GeneralConfig
    include Singleton

    attr_reader :config, :file
    def initialize
      @log = SCParser::ParserLogger.instance
      @file = get_file
      @config = get_config
    end

    def get_config
      begin
        YAML.load(File.read @file)
      rescue => e
        @log.fatal e.message
        @log.abort e.backtrace.join "\n"
      end
    end

    def file_config(dict_name)
      if config[dict_name].nil?
        @log.abort "Dictionary #{dict_name} not found"
      else
        config[dict_name]
      end
    end

    def filename(dict_name)
      if file_config(dict_name)['filename'].nil?
        @log.abort "Field File name not found for #{dict_name} description"
      end

      file_config(dict_name)['filename']
    end

    def filetype(dict_name)
      if file_config(dict_name)['filetype'].nil?
        @log.abort "Field File type not found for #{dict_name} description"
      end

      file_config(dict_name)['filetype']
    end

    def dictionary_type(dict_name)
      if file_config(dict_name)['dictionary_type'].nil?
        @log.abort "Field Dictionary type not found for #{dict_name} description"
      end

      file_config(dict_name)['dictionary_type']
    end

    private
    def get_file
      File.expand_path(File.join(SCParser::Application.properties[:config_path], 'dictionaries.yml'))
    end
  end
end