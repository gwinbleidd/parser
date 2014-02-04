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

  Dictionary.logger.info "Config: #{conf.table}" unless conf.table.nil?
  Dictionary.logger.info "Foreign keys: #{conf.foreign_keys}" unless conf.foreign_keys.nil?
  Dictionary.logger.info "Key columns: #{conf.key_columns}" unless conf.key_columns.nil?
  Dictionary.logger.info "Primary keys: #{conf.primary_keys}" unless conf.primary_keys.nil?
  Dictionary.logger.info "Output config: #{conf.output_config}" unless conf.output_config.nil?

  dict = Dictionary::Record.new(conf.config)

  models = Dictionary::Model.new(conf.table)

  models.objects.each do |o|
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

        rec = o.find_by v

        if rec.nil?
          o.create v
          inserted += 1
        else
          found += 1
        end

        if i == size
          Dictionary.logger.info("#{o.to_s.gsub(conf.name.to_s.capitalize, '')}: Processed #{i} of #{size} records, inserted #{inserted}, found #{found}")
        else
          print "Processing #{i} of #{size} records\r" if i % mod == 0
        end
      end unless record_value[o.table_name.to_s.downcase.sub(conf.name + '_', '').to_sym].nil?
    end
  end

  out = Dictionary::OutputFile.new(conf)

  out.start(models)
end

inp.finalize
