require 'config_file'

class FileLoader
  attr_reader :config, :files, :dictionaries

  def initialize
    cf = ConfigFile.new
    @config = cf.config

    $log.info("Start working")

    @dictionaries = Array.new if @dictionaries.nil?

    Dir.entries('../dictionaries').each do |e|
      @config.each do |key, value|
        if e =~ value['filename']
          $log.info(" Found file #{e}")

          @files = Array.new if @files.nil?

          if ProcessedFiles.find_by(:file_name => e) == nil
            @dictionaries.push key if @dictionaries.index(key).nil?

            @files.append File.expand_path(e, '../dictionaries')

            case value['filetype']
              when "zip" then
                unzip(File.expand_path(e, '../dictionaries'), key)
              when "text" then
                copy(File.expand_path(e, '../dictionaries'), key)
              else
                $log.fatal "Unknown filetype #{filetype} in #{key}"
                exit
            end

            $log.info(" #{e} belongs to #{key}")
          else
            $log.info(" #{e} belonging to #{key} already processed")
            @processed_files.nil? ? @processed_files = Array.new : @processed_files.append(File.expand_path(e, '../dictionaries'))
          end
        end
      end
    end

    if @files.nil?
      $log.info("No new files found")
    end
  end

  def finalize
    unless @files.nil?
      @files.each do |file|
        ProcessedFiles.create(file_name: File.basename(file), file_md5: Digest::MD5.file(file).hexdigest.to_s)
        FileUtils.move(file, File.join(File.dirname(file), 'processed', File.basename(file)))
      end
    end

    unless @processed_files.nil?
      @processed_files.each do |file|
        FileUtils.move(file, File.join(File.dirname(file), 'processed', File.basename(file)))
      end
    end

    @config.each do |key, value|
      FileUtils.rm_rf File.join(File.expand_path("../tmp"), key) if File.directory? File.join(File.expand_path("../tmp"), key)
    end
  end

  private
  def copy(filename, path)
    f_path=File.join(File.dirname(File.dirname(filename)), '/tmp', path, File.basename(filename).gsub('.', '_'), 'file.txt')
    FileUtils.mkdir_p(File.dirname(f_path))
    FileUtils.copy(filename, f_path) unless File.exist?(f_path)
  end

  def unzip(filename, path)
    Zip::File.open(filename) { |zip_file|
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