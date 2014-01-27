require 'zip/zip'
require 'processed_files'

module Dictionary
  class InputFile
    attr_reader :config, :files, :dictionaries

    def initialize
      Dictionary.logger.info("Starting create InputFiles")
      @config||= YAML.load(File.read '../config/dictionaries.yml')

      validate @config

      @config
    end

    def start
      @files = Array.new

      Dir.entries('../dictionaries').each do |e|
        Dictionary.logger.debug(" Processing file #{e}")
        @config.each do |key, value|
          if e =~ value['filename']
            @dictionaries = Array.new if @dictionaries.nil?
            @dictionaries.push key if @dictionaries.index(key).nil?
            Dictionary.logger.info(" Found file #{e}")
            @files.append File.expand_path(e, '../dictionaries')

            case value['filetype']
              when "zip" then unzip((File.expand_path(e, '../dictionaries')), key)
              else
                Dictionary.logger.fatal "Unknown filetype #{filetype} in #{key}"
                exit
            end
          end
        end
      end

      @files
    end

    def finalize
      @config||= YAML.load(File.read '../config/dictionaries.yml') unless @config.nil?

      if @files.nil?
        Dictionary.logger.fatal "No file list"
      else
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