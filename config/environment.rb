require 'rubygems'
require 'active_record'
require 'yaml'
require 'load_path'

LoadPath.configure do
  add parent_directory('.', up: 1)
  add path_builder { sibling_directory('lib') }
  add path_builder { sibling_directory('lib').child_directory('models') }
  add path_builder { sibling_directory('db') }
  add path_builder { sibling_directory('config') }
end

require 'model'
require 'output_file'
require 'input_file'
require 'dictionary_table_migration'
require 'dictionary_uniq_const_migration'
require 'dictionary_view_migration'
require 'muti_io'
require '../lib/output'
require 'joined'

# Загружаем файл настройки соединения с БД
dbconfig = YAML::load(File.open(File.join(File.dirname(__FILE__), 'database.yml')))

# Ошибки работы с БД направим в стандартный поток (консоль)
ActiveRecord::Base.logger = Logger.new(File.expand_path(File.join(File.dirname(__FILE__), "../log/db.log"))) # Simple logging utility. logger.rb -- standart lib
ActiveRecord::Base.logger.level = Logger::DEBUG

# Соединяемся с БД
ActiveRecord::Base.establish_connection(dbconfig)
