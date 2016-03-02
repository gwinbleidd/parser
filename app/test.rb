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

fp = SCParser::FileProcessor.new
fp.process_files

fp.files.each do |dictionary_name, files|

  dp = SCParser::DictionaryProcessor.new(name: dictionary_name, files: files)
  dp.process_files
  of = SCParser::OutputFile.new(name: dictionary_name)
  of.process
  fp.finalize(dictionary_name: dictionary_name, files: files)
end


