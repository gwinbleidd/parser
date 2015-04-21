# encoding: utf-8
require File.join(File.dirname(__FILE__), '../config/environment.rb')

conf = Configuration.new('mkd')

$log.debug "Table: #{conf.table}" unless conf.table.nil?
$log.debug "Foreign keys: #{conf.foreign_keys}" unless conf.foreign_keys.nil?
$log.debug "Key columns: #{conf.key_columns}" unless conf.key_columns.nil?
$log.debug "Primary keys: #{conf.primary_keys}" unless conf.primary_keys.empty?
$log.debug "Input config: #{conf.input_config}" unless conf.output_config.nil?
$log.debug "Output config: #{conf.output_config}" unless conf.output_config.nil?
$log.debug "Header config: #{conf.header}" unless conf.header.nil?