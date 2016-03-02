module SCParser
  #checking files in <dictionary> directory and unzipping or copying them to temporary directory

  class FileProcessor
    attr :files

    def initialize
      @log = SCParser::ParserLogger.instance

      @general_config = SCParser::GeneralConfig.instance

      @log.info("Start working")

      @processed_files = Array.new

      @files = Hash.new
    end

    def finalize(params)
      unless params[:files].nil?
        params[:files].each do |file|
          ProcessedFiles.create(name: params[:dictionary_name], file_name: file, file_md5: Digest::SHA256.file(File.expand_path(file, '../dictionaries')).hexdigest.to_s)
          FileUtils.move(File.expand_path(file, '../dictionaries'), File.expand_path(file, '../dictionaries/processed'))
        end
      end

      unless @processed_files.nil?
        @processed_files.each do |file|
          FileUtils.move(file, File.join(File.dirname(file), 'processed', File.basename(file)))
        end
      end

      FileUtils.rm_rf File.join(File.expand_path("../tmp"), params[:dictionary_name]) if File.directory? File.join(File.expand_path("../tmp"), params[:dictionary_name])
      @log.info "#{params[:dictionary_name]} finalized"
    end


    def process_files
      @files = files_to_process

      if @files.empty?
        @log.info("No new files found")
      else
        @files.each do |dict_name, file_names|
          case @general_config.filetype(dict_name)
            when 'zip' then
              file_names.each { |file|
                @log.info " Unzipping #{file} for #{dict_name}"
                unzip(File.join(SCParser::Application.properties[:dictionaries_path], file), dict_name)
              }
            when 'text'
              file_names.each { |file|
                @log.info " Copying #{file} for #{dict_name}"
                copy(File.join(SCParser::Application.properties[:dictionaries_path], file), dict_name)
              }
            else
              @log.abort "Unknown filetype #{@general_config.filetype(dict_name)} for #{dict_name}"
          end
        end

        @log.info 'Files moved to temporary directory and ready for uploading'
      end
    end

    def files_to_process
      result = Hash.new

      begin
        Dir.entries(SCParser::Application.properties[:dictionaries_path]).select do |e|
          if File.file?(File.join(SCParser::Application.properties[:dictionaries_path], e))
            checking_file = check_file(e)
            unless checking_file.empty?
              result[checking_file.keys[0]] = Array.new if result[checking_file.keys[0]].nil?
              result[checking_file.keys[0]].append e
            end
          end
        end
      rescue => e
        @log.fatal e.message
        @log.abort e.backtrace.join "\n"
      end

      result
    end

    private
    def check_file(filename)
      result = Hash.new

      begin
        @general_config.config.each do |dict_name, dict_desc|
          if filename =~ dict_desc['filename']

            @log.info "File #{filename} belongs to #{dict_name}"

            if ProcessedFiles.find_by(:file_name => filename).nil?
              result[dict_name] = filename
            else
              @log.info(" #{filename} belonging to #{dict_name} already processed")
              @processed_files.append(File.expand_path(filename, SCParser::Application.properties[:dictionaries_path]))
            end
          end
        end

        raise "File #{filename} belongs more than one dictionary" if result.size > 1
      rescue => e
        @log.fatal e.message
        @log.abort e.backtrace.join "\n"
      end

      result
    end

    def unzip(filename, path)
      Zip::File.open(filename) { |zip_file|
        zip_file.each { |f|
          f_path=File.join(SCParser::Application.properties[:tmp_path], path, File.basename(filename).gsub('.', '_'), f.name)
          FileUtils.mkdir_p(File.dirname(f_path))
          zip_file.extract(f, f_path) unless File.exist?(f_path)
        }
      }
    end

    def copy(filename, path)
      f_path=File.join(SCParser::Application.properties[:tmp_path], path, File.basename(filename).gsub('.', '_'), 'file.txt')
      FileUtils.mkdir_p(File.dirname(f_path))
      FileUtils.copy(filename, f_path) unless File.exist?(f_path)
    end
  end
end