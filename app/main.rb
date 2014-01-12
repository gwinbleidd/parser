# encoding: utf-8
require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require './models/dictionary'
require '../app/dictionary_config'
require '../db/dictionary_migration'
require '../app/dictionary_records'

require File.join(File.dirname(__FILE__), '../config/environment.rb')

def create_activerecord_class table_name
  Class.new(ActiveRecord::Base) do
    self.table_name = table_name
  end
end

conf = DictionaryConfig.new('fryazinovo')

dict = DictionaryRecords.new(conf.config)

#records = dict.get_records('fryazinovo')
#
#dict.config['dictionaries'].each { |key, value|
#  table = Hash.new
#  table['name'] = (dict.name.to_s.downcase + '_' + key.to_s.downcase)
#  table['fields'] = value['fields']
#  #table[dict.name.to_s.capitalize + key.to_s.capitalize] = value
#  DictionaryMigration.up(table)
#  dictionary = create_activerecord_class(table['name'])
#  records[key].each {|k,v|
#    dictionary.create v
#  }
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

File.open("../records.yml", "w+") do |file|
  file.write dict.records.to_yaml
end
