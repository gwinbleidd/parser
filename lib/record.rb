module Dictionary
  require 'dbf'

  class Record
    attr_reader :records, :name

    def initialize(config)
      Dictionary.logger.debug "Starting create Records for #{config}"
      @records = Hash.new
      filename = nil

      dict_name = config['name']

      paths = Pathname.new(File.expand_path('../.') + '/tmp/' + dict_name).children.select { |c| c.directory? }.collect { |p| p.to_s }

      paths.each do |path|
        @records[File.basename path.gsub('_', '.')] = Hash.new

        config['dictionaries'].each do |dictionary_key, dictionary_value|
          @records[File.basename path.gsub('_', '.')][dictionary_key.to_s.downcase.pluralize.to_sym] = Hash.new

          if dictionary_value['format'] == 'txt'
            Dictionary.logger.debug " Processing text file for #{config}"
            if File.exist?(path + '/' + dictionary_key.to_s + '.txt')
              filename = File.open(path.to_s + '/' + dictionary_key.to_s + '.txt')
            else
              Dictionary.logger.error "File #{path.to_s + '/' + dictionary_key.to_s}.txt doesn\'t exist"
              exit
            end

            delimiter = dictionary_value['delimiter'].to_i.chr(dictionary_value['encoding'].to_s)

            index = 0

            filename.each do |line|
              index += 1
              line = line.to_s.encode('UTF-8', dictionary_value['encoding'].to_s).delete("\r\n")
              @records[File.basename path.gsub('_', '.')][dictionary_key.to_s.downcase.pluralize.to_sym][index] = is_record(line, delimiter.encode('UTF-8'), dictionary_value['fields'])
            end

          elsif dictionary_value['format'] == 'dbf'
            Dictionary.logger.debug " Processing DBase file for #{config}"
            if File.exist?(path + '/' + dictionary_key.to_s + '.dbf')
              Dictionary.logger.debug "   Filename #{path.to_s}/#{dictionary_key.to_s}.dbf"
              filename = DBF::Table.new("#{path.to_s}/#{dictionary_key.to_s}.dbf", nil, dictionary_value['encoding'].to_s)
            else
              Dictionary.logger.error "File #{path.to_s + '/' + dictionary_key.to_s}.dbf doesn\'t exist"
              exit
            end

            index = 0

            filename.each do |record|
              index += 1
              record.attributes.each do |key, value|
                @records[File.basename path.gsub('_', '.')][dictionary_key.to_s.downcase.pluralize.to_sym][index] = Hash.new if @records[File.basename path.gsub('_', '.')][dictionary_key.to_s.downcase.pluralize.to_sym][index].nil?
                @records[File.basename path.gsub('_', '.')][dictionary_key.to_s.downcase.pluralize.to_sym][index][key.to_s.downcase.to_sym.to_s] = value.to_s.encode( 'UTF-8', dictionary_value['encoding'])
              end
            end
          end
        end
      end
    end

    private
    def records=(m)
      @records = m
    end

    def name=(m)
      @name = m
    end

    def is_record(line, delimiter, fields)
      splitted_line = split_line(line, delimiter)

      if splitted_line.size == fields.size
        @is_record = Hash.new

        splitted_line.each { |line_key, line_value|
          @is_record[fields[line_key]['name'].to_s.to_sym] = line_value
        }
      else
        puts "Line \"#{line}\" don't correspond to config"
        exit
      end

      @is_record
    end

    def split_line(line, delimiter)
      @split_line = Hash.new

      index = 0

      line.to_s.split(delimiter).each { |arr|
        index += 1
        @split_line["column" + index.to_s] = arr
      }

      @split_line
    end
  end
end