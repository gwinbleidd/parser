require File.expand_path(File.join(File.dirname(__FILE__), '../config/environment.rb'))

@log = SCParser::ParserLogger.instance
#
# dc = SCParser::DictionaryConfig.new('visis')
#
# puts "Table def: #{dc.table}"
# puts "Foreign keys: #{dc.foreign_keys}"
# puts "Primary keys: #{dc.primary_keys}"
# puts "Key columns: #{dc.key_columns}"
# puts "Side files: #{dc.side_files}"

conf = SCParser::DictionaryConfig.new('vsc')

@log.info "Table: #{conf.table[:name]}"
DictionaryTableMigration.up(conf.table[:name], conf.table[:fields])
DictionaryUniqConstMigration.up(conf.table) unless conf.table.nil?

#DictionaryTableMigration.down(conf.table[:name], conf.table[:fields])
