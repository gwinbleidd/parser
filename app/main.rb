require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require './models/dictionary'
require '../app/dictionary_config'
require '../db/dictionary_migration'

require File.join(File.dirname(__FILE__), '../config/environment.rb')

def create_activerecord_class table_name
  Class.new(ActiveRecord::Base) do
    self.table_name = table_name
  end
end

dict = DictionaryConfig.new

records = dict.get_records('fryazinovo')
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

dictionary = create_activerecord_class('fryazinovo_street')

puts dictionary