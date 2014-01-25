# encoding: utf-8
require File.join(File.dirname(__FILE__), '../config/environment.rb')

require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'

inp = Dictionary::InputFile.new

inp.config.each do |c|
  conf = Dictionary::Configuration.new(c)

  Dictionary.logger.warn "Foreign keys: #{conf.foreign_keys}"
  Dictionary.logger.warn "Key columns: #{conf.key_columns}"
  Dictionary.logger.warn "Primary keys: #{conf.primary_keys}"
  Dictionary.logger.warn "Output config: #{conf.output_config}"

  dict = Dictionary::Record.new(conf.config)

  records = dict.records

  mdls = Dictionary::Model.new(conf.table)

  mdls.objects.each { |o|
    records.each do |record_key, record_value|
      size = record_value[o.to_s.downcase.sub(conf.name, '').to_sym].size
      case size
        when 0 .. 10 then mod = 1
        when 11 .. 1000 then mod = 5
        when 1001 .. 10000 then mod = 100
        when 10001 .. 50000 then mod = 500
        else
          mod = 1000
      end

      i = 0

      record_value[o.to_s.downcase.sub(conf.name, '').to_sym].each { |k, v|
        i += 1
        if i == size
          puts "#{o.to_s.gsub(conf.name.to_s.capitalize, '')}: Processed #{i} of #{size} records\n"
          Dictionary.logger.warn("#{o.to_s.gsub(conf.name.to_s.capitalize, '')}: Processed #{i} of #{size} records")
        else
          print "Processing #{i} of #{size} records\r" if i % mod == 0
        end
        rec = o.find_by v

        if rec.nil?
          o.create v
        end
      }
    end
  }

  out = Dictionary::OutputFile.new(conf)

  out.start(mdls)
end

inp.finalize
