require 'zip/zip'
require 'processed_files'

module Dictionary
  class InputFile
    attr_reader :config, :files, :dictionaries

    def initialize
      Dictionary.logger.info("Starting create InputFiles")
      @config||= YAML.load(File.read '../config/dictionaries.yml')

      validate conf

      @config.each do |key, value|
        @dictionaries = Array.new if @config.nil?
        @dictionaries.append key
      end

      @config
    end

    def start
      @files = Array.new

      #TODO: неправильный цикл, переделать на один цикл по каталогу - много циклов по справочнику

      Dir.entries('../dictionaries').each do |e|
        Dictionary.logger.info(" InputFile -- #{key}, #{value}")
        @config.each do |key, value|
          Dictionary.logger.debug(" Processing file #{e}")
          if e =~ value['filename']
            Dictionary.logger.debug(" Found file #{e}")
            @files.append File.expand_path(e, '../dictionaries')

            case value['filetype']
              when "zip" then unzip((File.expand_path(e, '../dictionaries')), key)
              else
                Dictionary.logger.error "Unknown filetype #{filetype} in #{key}"
                exit
            end
          end
        end
      end

      @files
    end

    def finalize
      @config||= YAML.load(File.read '../config/dictionaries.yml') unless @config.nil?

      unless @files.nil?
        @files.each do |file|
          ProcessedFiles.create(file_name: File.basename(file), file_md5: Digest::MD5.file(file).hexdigest.to_s)
        end
      end

      @config.each do |key, value|
        FileUtils.rm_rf File.join(File.expand_path("../tmp") ,key) if File.directory? File.join(File.expand_path("../tmp"), key)
      end
    end

    private
    def unzip(filename, path)
      Zip::ZipFile.open(filename) { |zip_file|
        zip_file.each { |f|
          f_path=File.join(File.dirname(File.dirname(filename)), '/tmp', path, File.basename(filename).gsub('.', '_'), f.name)
          FileUtils.mkdir_p(File.dirname(f_path))
          zip_file.extract(f, f_path) unless File.exist?(f_path)
        }
      }
    end

    def validate(config)
      #TODO: create config validation procedure
      config
    end

    def config=(m)
      @config = m
    end

    def files=(m)
      @files = m
    end

    def dictionaries=(m)
      @dictionaries = m
    end
  end
end