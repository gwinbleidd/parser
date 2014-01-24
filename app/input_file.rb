require 'zip/zip'

module Dictionary
  class InputFile
    def initialize
      @config||= YAML.load(File.read '..\config\dictionaries.yml')

      validate @config

      @files= Array.new

      @config.each do |key, value|
        Dir.entries('../dictionaries').each do |e|
          if e =~ value['filename']
            @files.append File.expand_path(e, '../dictionaries')

            case value['filetype']
              when "zip" then unzip((File.expand_path(e, '../dictionaries')), key)
              else
                puts "Unknown filetype #{filetype} in #{key}"
                exit
            end
          end
        end
      end
    end

    def finalize
      @config||= YAML.load(File.read '..\config\dictionaries.yml')

      puts @config

      @config.each do |key, value|
        Dir.entries(File.expand_path("../dictionaries/#{key}")).each do |e|
          FileUtils.rm_rf File.join(File.expand_path("../dictionaries/#{key}"), e) if File.directory? File.join(File.expand_path("../dictionaries/#{key}"), e) and !(e =='.' || e == '..')
        end
      end
    end

    private
    def unzip(filename, path)
      Zip::ZipFile.open(filename) { |zip_file|
        zip_file.each { |f|
          f_path=File.join(File.dirname(filename), path, File.basename(filename).gsub('.', '_'), f.name)
          FileUtils.mkdir_p(File.dirname(f_path))
          zip_file.extract(f, f_path) unless File.exist?(f_path)
        }
      }
    end

    def validate(config)
      config
    end
  end
end