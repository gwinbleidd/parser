# encoding: utf-8
require File.join(File.dirname(__FILE__), 'config/environment.rb')

require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require 'dictionary'
require 'output_file'
require 'input_file'
require 'dictionary_table_migration'
require 'dictionary_uniq_const_migration'
require 'dictionary_view_migration'

#puts "Foreign keys: #{conf.foreign_keys}"
#puts "Key columns: #{conf.key_columns}"
#puts "Primary keys: #{conf.primary_keys}"
#puts "Output config: #{conf.output_config}"

inp = Dictionary::InputFile.new

inp.config.each do |c|
  conf = Dictionary::Config.new(c)

  dict = Dictionary::Record.new(conf.config)

  records = dict.records

  mdls = Dictionary::Model.new(conf.table)

  mdls.objects.each { |o|
    records.each do |record_key, record_value|
      puts record_key
      record_value[o.to_s.downcase.sub(conf.name, '').to_sym].each { |k, v|
        rec = o.find_by v

        if rec.nil?
          o.create v
        else
          puts rec
        end
      }
    end
  }

  out = Dictionary::OutputFile.new(conf)

  out.start
end

inp.finalize

#mdls.main_view.all.each { |rec|
#  record = Hash.new
#
#  conf.output_config['fields'].each { |key, value|
#    if value['from'].is_a?(String)
#      record[value['name'].to_sym] = eval 'rec.' + value['from'].to_s
#    elsif value['from'].is_a?(Array)
#      fields = Array.new
#      value['from'].each { |item| fields.push 'rec.' + item }
#      record[value['name'].to_sym] = eval fields.join "+\"#{value['delimiter']}\"+"
#    end
#  }
#
#  puts record
#}

#conf.table.each { |key, value|
#  #puts "Table: #{key.to_s.pluralize} #{value}"
#  DictionaryViewMigration.up(key.to_s.pluralize, value)
#}

#DictionaryTableMigration.up(table)
#dictionary = create_activerecord_class(table)
#
#puts "#{table['name']}: #{dictionary.instance_methods.sort}"
#puts "#{table['name']}: #{dictionary.class}, #{dictionary.superclass}"
#records[key.to_s.to_sym].each {|k,v|
#  rec = dictionary.find_by v
#
#  if rec == nil
#    dictionary.create v
#  else
#    puts "#{rec.to_yaml}"
#  end
#}

#dict.config['dictionaries']['street']['fields'].each {|key, value|
#  puts "#{key}, #{value}"
#
#  if value['key'] != nil
#    if key_columns[value['key'].to_sym] == nil
#      key_columns[value['key'].to_sym] = Hash.new
#    end
#    key_columns[value['key'].to_sym][value['name'].to_sym] = ''
#  end
#}
#key_columns[:ak1][:streetId] = 29
#key_columns[:ak1][:streetName] = 'ул. Авксентьевского'.encode('UTF-8')
#
#puts key_columns
#
#dictionary = create_activerecord_class('fryazinovo_street')
#
#record = dictionary.find_by key_columns[:ak1]
#
#puts "#{record.streetId}, #{record.streetName}"

#File.open("../records.yml", "w+") do |file|
#  file.write dict.records.to_yaml
#end
