# encoding: utf-8
require File.join(File.dirname(__FILE__), '../config/environment.rb')

require 'rubygems'
require 'active_record'
require 'yaml'
require '../lib/config_file'

conf = Configuration.new('mkd')

$log.info "Table: #{conf.table[:name]}"
DictionaryTableMigration.up(conf.table[:name], conf.table[:fields])
DictionaryUniqConstMigration.up(conf.table) unless conf.table.nil?
