# encoding: utf-8
require File.join(File.dirname(__FILE__), '../config/environment.rb')

require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require 'dictionary'
require '../db/dictionary_table_migration'
require '../db/dictionary_uniq_const_migration'

conf = Dictionary::Config.new('fryazinovo')

dict = Dictionary::Record.new(conf.config)

records = dict.records

def create_activerecord_class(table)
  attrs = Array.new

  table[:fields].each { |key, value|
    attrs.push value.to_sym
  }

  Class.new(ActiveRecord::Base) do
    self.table_name = table[:name]

    self.send(:attr_accessor, *attrs)
  end
end

puts "Foreign keys: #{conf.foreign_keys}"
puts "Key columns: #{conf.key_columns}"
puts "Primary keys: #{conf.primary_keys}"
puts "Output config: #{conf.output_config}"

#puts records[:street]

conf.config['dictionaries'].each { |key, value|
  table = Hash.new
  table[:name] = (conf.name.to_s.downcase + '_' + key.to_s.downcase)
  table[:fields] = Hash.new
  value['fields'].each {|column_name, column_code|
    table[:fields][column_name.to_sym] = column_code['name']
  }
  if conf.primary_keys[key][:pk] != nil
    table[:pk] = conf.primary_keys[key][:pk].to_s
  end

  if conf.key_columns[key] != nil
    #puts conf.foreign_keys[key]
    table[:fk] = conf.foreign_keys[key]
  end


  puts table

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
}

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
