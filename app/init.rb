# encoding: utf-8
require File.join(File.dirname(__FILE__), '../config/environment.rb')

require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'

inp = Dictionary::InputFile.new

inp.config.each do |c|
  conf = Dictionary::Configuration.new(c)

  conf.table.each { |key, value|
    #Dictionary.logger.info "Table: #{key.to_s.pluralize}, #{value}"
    #DictionaryTableMigration.up(key.to_s.pluralize, value[:fields])
    #DictionaryViewMigration.up(key.to_s.pluralize, value)
  }

  DictionaryUniqConstMigration.up(conf.table) unless conf.table.nil?
end