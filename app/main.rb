# encoding: utf-8
require File.join(File.dirname(__FILE__), '../config/environment.rb')

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

  join = Hash.new

  dict.records.each do |key, value|
    join[key] = Dictionary::Joined.new(conf, value)
  end

  out = Hash.new

  join.each do |key, value|
    out[key] = Dictionary::Output.new(conf, value.joined)
  end

  models = Dictionary::Model.new(conf.table)

  models.objects.each do |o|
    if inp.config[c].has_key?('type')
      case inp.config[c]['type']
        when 'clear' then
          o.delete_all

          dict.records.each do |record_key, record_value|
            record_value[o.table_name.to_s.downcase.sub(conf.name + '_', '').to_sym].nil? ? size = 0 : size = record_value[o.table_name.to_s.downcase.sub(conf.name + '_', '').to_sym].size

            case size
              when 0 .. 10 then
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

            record_value[o.table_name.to_s.downcase.sub(conf.name + '_', '').to_sym].each do |k, v|
              i += 1

              o.create v
              inserted += 1

              if i == size
                Dictionary.logger.info("#{o.to_s.gsub(conf.name.to_s.capitalize, '')}: Processed #{i} of #{size} records, inserted #{inserted}, found #{found}")
              else
                print "Processing #{i} of #{size} records\r" if i % mod == 0 or i == 1
              end
            end unless record_value[o.table_name.to_s.downcase.sub(conf.name + '_', '').to_sym].nil?
          end

        when 'update' then
          dict.records.each do |record_key, record_value|
            if conf.primary_keys[o.to_s.downcase.sub(conf.name,'')].nil?
              Dictionary.logger.fatal("Primary key not set for #{o.table_name}")
              raise "Primary key not set for #{o.table_name}"
            end

            record_value[o.table_name.to_s.downcase.sub(conf.name + '_', '').to_sym].nil? ? size = 0 : size = record_value[o.table_name.to_s.downcase.sub(conf.name + '_', '').to_sym].size

            case size
              when 0 .. 10 then
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

            unless record_value[o.table_name.to_s.downcase.sub(conf.name + '_', '').to_sym].nil?
              record_value[o.table_name.to_s.downcase.sub(conf.name + '_', '').to_sym].each do |k, v|
                i += 1
                rec = nil

                case conf.primary_keys[o.to_s.downcase.sub(conf.name, '')][:type]
                  when 'string' then
                    rec = o.find_by conf.primary_keys[o.to_s.downcase.sub(conf.name, '')][:name] => v[conf.primary_keys[o.to_s.downcase.sub(conf.name, '')][:name]].to_s
                  when 'integer' then
                    rec = o.find_by conf.primary_keys[o.to_s.downcase.sub(conf.name, '')][:name] => v[conf.primary_keys[o.to_s.downcase.sub(conf.name, '')][:name]].to_i
                  else
                    Dictionary.logger.fatal("Unknown primary key type for #{o.table_name}")
                    raise "Unknown primary key type for #{o.table_name}"
                end

                if rec.nil?
                  o.create v
                  inserted += 1
                else
                  rec.update v
                  found += 1
                end

                if i == size
                  Dictionary.logger.info("#{o.to_s.gsub(conf.name.to_s.capitalize, '')}: Processed #{i} of #{size} records, inserted #{inserted}, found #{found}")
                else
                  print "Processing #{i} of #{size} records\r" if i % mod == 0 or i == 1
                end
              end
            end
          end

        when 'append' then
          dict.records.each do |record_key, record_value|
            record_value[o.table_name.to_s.downcase.sub(conf.name + '_', '').to_sym].nil? ? size = 0 : size = record_value[o.table_name.to_s.downcase.sub(conf.name + '_', '').to_sym].size

            case size
              when 0 .. 10 then
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

            record_value[o.table_name.to_s.downcase.sub(conf.name + '_', '').to_sym].each do |k, v|
              i += 1

              o.create v
              inserted += 1

              if i == size
                Dictionary.logger.info("#{o.to_s.gsub(conf.name.to_s.capitalize, '')}: Processed #{i} of #{size} records, inserted #{inserted}, found #{found}")
              else
                print "Processing #{i} of #{size} records\r" if i % mod == 0 or i == 1
              end
            end unless record_value[o.table_name.to_s.downcase.sub(conf.name + '_', '').to_sym].nil?
          end
        else
          Dictionary.logger.fatal("Unknown type #{inp.config[c]['type']} of dictionary #{c}")
          exit
      end
    else
      Dictionary.logger.fatal("Dictionary #{c} does not have type")
      exit
    end
  end

  out = Dictionary::OutputFile.new(conf)

  out.start(models)
end

inp.finalize
