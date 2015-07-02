require 'dbf'

class Record
  attr_reader :records, :name

  def initialize(config)
    $log.info "Starting loading records into memory for #{config.name}"
    @records = Hash.new
    filename = nil

    dict_name = config.name

    paths = Pathname.new(File.expand_path('../.') + '/tmp/' + dict_name).children.select { |c| c.directory? }.collect { |p| p.to_s }

    paths.each do |path|
      @records[File.basename path.gsub('_', '.')] = Hash.new

      config.input_config['dictionaries'].each do |dictionary_key, dictionary_value|
        @records[File.basename path.gsub('_', '.')][dictionary_key.to_s.downcase.pluralize.to_sym] = Hash.new

        dictionary_value.has_key?('startfrom') ? start = dictionary_value['startfrom'] : start = 1

        if dictionary_value['format'] == 'txt'
          $log.debug " Processing text file for #{config.name}"
          if File.exist?(path + '/' + dictionary_key.to_s + '.txt')
            filename = File.open(path.to_s + '/' + dictionary_key.to_s + '.txt')
          else
            $log.error "File #{path.to_s + '/' + dictionary_key.to_s}.txt doesn\'t exist"
            exit
          end

          delimiter = dictionary_value['delimiter'].to_i.chr(dictionary_value['encoding'].to_s)

          index = 0

          filename.each do |line|
            index += 1
            if index >= start
              line = line.to_s.encode('UTF-8', dictionary_value['encoding'].to_s)
              @records[File.basename path.gsub('_', '.')][dictionary_key.to_s.downcase.pluralize.to_sym][index] = is_record(index, line, delimiter.encode('UTF-8'), dictionary_value['fields'])
            end
          end

        elsif dictionary_value['format'] == 'dbf'
          $log.debug " Processing DBase file for #{config.name}"
          if File.exist?(path + '/' + dictionary_key.to_s + '.dbf')
            $log.debug "   Filename #{path.to_s}/#{dictionary_key.to_s}.dbf"
            filename = DBF::Table.new("#{path.to_s}/#{dictionary_key.to_s}.dbf", nil, dictionary_value['encoding'].to_s)
          else
            $log.error "File #{path.to_s + '/' + dictionary_key.to_s}.dbf doesn\'t exist"
            exit
          end

          index = 0

          filename.each do |record|
            index += 1
            record.attributes.each do |key, value|
              @records[File.basename path.gsub('_', '.')][dictionary_key.to_s.downcase.pluralize.to_sym][index] = Hash.new if @records[File.basename path.gsub('_', '.')][dictionary_key.to_s.downcase.pluralize.to_sym][index].nil?
              @records[File.basename path.gsub('_', '.')][dictionary_key.to_s.downcase.pluralize.to_sym][index][key.to_s.downcase.to_sym.to_sym] = value.to_s.encode('UTF-8', dictionary_value['encoding'])
            end
          end
        else
          $log.fatal "Unknown format"
          raise "Unknown format"
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

  def is_record(index, line, delimiter, fields)
    splitted_line = split_line(line, delimiter)

    is_record = Hash.new

    if splitted_line.size == fields.size
      splitted_line.each { |line_key, line_value|
        is_record[fields[line_key]['name'].to_sym] = line_value
      }
    else
      $log.fatal "Row #{index}: Line \"#{line}\" don't correspond to config"
      exit
    end

    is_record
  end

  def split_line(line, delimiter)
    split_line = Hash.new

    index = 0

    line.to_s.split(delimiter).each { |arr|
      index += 1
      split_line["column" + index.to_s] = arr.delete("\r\n")
    }

    split_line
  end
end