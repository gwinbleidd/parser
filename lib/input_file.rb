require 'zip/zip'

module Dictionary
  class InputFile
    attr_reader :config

    def initialize
      conf||= YAML.load(File.read '../config/dictionaries.yml')

      validate conf

      files= Array.new

      conf.each do |key, value|
        @config = Array.new if @config.nil?
        @config.push key
        Dir.entries('../dictionaries').each do |e|
          if e =~ value['filename']
            files.append File.expand_path(e, '../dictionaries')

            case value['filetype']
              when "zip" then unzip((File.expand_path(e, '../dictionaries')), key)
              else
                puts "Unknown filetype #{filetype} in #{key}"
                exit
            end
          end
        end
      end

      @config
    end

    def finalize
      @config||= YAML.load(File.read '../config/dictionaries.yml')

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
  end
end