# encoding: utf-8
require File.join(File.dirname(__FILE__), '../config/environment.rb')

ENV['ENV'] = 'development'

require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'

inp = Dictionary::InputFile.new

inp.start

inp.dictionaries.each do |c|
  conf = Dictionary::Configuration.new(c)

  Dictionary.logger.debug "Config: #{conf.table}" unless conf.table.nil?
  Dictionary.logger.debug "Foreign keys: #{conf.foreign_keys}" unless conf.foreign_keys.nil?
  Dictionary.logger.debug "Key columns: #{conf.key_columns}" unless conf.key_columns.nil?
  Dictionary.logger.debug "Primary keys: #{conf.primary_keys}" unless conf.primary_keys.nil?
  Dictionary.logger.debug "Output config: #{conf.output_config}" unless conf.output_config.nil?

  dict = Dictionary::Record.new(conf.config)

  out = Hash.new

  dict.records.each do |key, value|
    Dictionary.logger.info("Starting creating output array of data for file #{key}")
    out[key] = Dictionary::Output.new(conf, Dictionary::Joined.new(conf, value).joined)
  end

  models = Dictionary::Model.new(conf.table)

  models.objects.each do |o|
    if inp.config[c].has_key?('type')
      case inp.config[c]['type']
        when 'clear' then
          o.delete_all

          out.each do |filename, filecontent|
            filecontent.records[:data].nil? ? size = 0 : size = filecontent.records[:data].size

            case size
              when 0 then
                raise "No data for #{o.to_s}"
              when 1 .. 10 then
                mod = 1
              when 11 .. 1000 then
                mod = 5
              when 1001 .. 10000 then
                mod = 100
              when 10001 .. 50000 then
                mod = 500
              else
                mod = 1000
            end

            found = inserted = i = 0

            filecontent.records[:data].each do |k, v|
              i += 1

              o.create v
              inserted += 1

              if i == size
                Dictionary.logger.info("#{o.to_s}: Processed #{i} of #{size} records, inserted #{inserted}, found #{found}")
              else
                print "Processing #{i} of #{size} records\r" if i % mod == 0 or i == 1
              end
            end
          end

        when 'update' then
          out.each do |filename, filecontent|
            if conf.table[o.to_s.downcase.to_sym][:keys].nil?
              Dictionary.logger.fatal("Key fields not set for #{o.table_name}")
              raise "Key fields not set for #{o.table_name}"
            end

            filecontent.records[:data].nil? ? size = 0 : size = filecontent.records[:data].size

            case size
              when 0 then
                raise "No data for #{o.to_s}"
              when 1 .. 10 then
                mod = 1
              when 11 .. 1000 then
                mod = 5
              when 1001 .. 10000 then
                mod = 100
              when 10001 .. 50000 then
                mod = 500
              else
                mod = 1000
            end

            found = inserted = i = 0

            filecontent.records[:data].each do |k, v|
              i += 1
              rec = nil

              sfields = Hash.new

              conf.table[o.to_s.downcase.to_sym][:keys].each do |keyfield|
                case keyfield[:type]
                  when 'string'
                    sfields[keyfield[:name]] = v[keyfield[:name]].to_s
                  when 'integer'
                    sfields[keyfield[:name]] = v[keyfield[:name]].to_i
                  else
                    Dictionary.logger.fatal("Unknown primary key type for #{o.table_name}")
                    raise "Unknown primary key type for #{o.table_name}"
                end
              end

              rec = o.find_by sfields

              if rec.nil?
                o.create v
                inserted += 1
              else
                rec.update v
                found += 1
              end

              if i == size
                Dictionary.logger.info("#{o.to_s}: Processed #{i} of #{size} records, inserted #{inserted}, found #{found}")
              else
                print "Processing #{i} of #{size} records\r" if i % mod == 0 or i == 1
              end
            end
          end

        when 'append' then
          out.each do |filename, filecontent|
            filecontent.records[:data].nil? ? size = 0 : size = filecontent.records[:data].size

            case size
              when 0 then
                raise "No data for #{o.to_s}"
              when 1 .. 10 then
                mod = 1
              when 11 .. 1000 then
                mod = 5
              when 1001 .. 10000 then
                mod = 100
              when 10001 .. 50000 then
                mod = 500
              else
                mod = 1000
            end

            found = inserted = i = 0

            filecontent.records[:data].each do |k, v|
              i += 1
              rec = nil

              sfields = Hash.new

              conf.table[o.to_s.downcase.to_sym][:keys].each do |keyfield|
                case keyfield[:type]
                  when 'string'
                    sfields[keyfield[:name]] = v[keyfield[:name]].to_s
                  when 'integer'
                    sfields[keyfield[:name]] = v[keyfield[:name]].to_i
                  else
                    Dictionary.logger.fatal("Unknown primary key type for #{o.table_name}")
                    raise "Unknown primary key type for #{o.table_name}"
                end
              end

              rec = o.find_by sfields

              o.create v
              inserted += 1

              if i == size
                Dictionary.logger.info("#{o.to_s}: Processed #{i} of #{size} records, inserted #{inserted}, found #{found}")
              else
                print "Processing #{i} of #{size} records\r" if i % mod == 0 or i == 1
              end
            end
          end
        else
          Dictionary.logger.fatal("Unknown type #{inp.config[c]['type']} of dictionary #{c}")
          raise "Unknown type #{inp.config[c]['type']} of dictionary #{c}"
      end
    else
      Dictionary.logger.fatal("Dictionary #{c} does not have type")
      raise "Dictionary #{c} does not have type"
    end
  end

  out = Dictionary::OutputFile.new(conf)

  out.start(models)
end

inp.finalize
