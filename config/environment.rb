require 'rubygems'
require 'active_record'
require 'yaml'
require 'load_path'
require 'logger'

LoadPath.configure do
  add parent_directory('.', up: 1)
  add path_builder { sibling_directory('lib') }
  add path_builder { sibling_directory('lib').child_directory('models') }
  add path_builder { sibling_directory('db') }
  add path_builder { sibling_directory('db').child_directory('migrate') }
  add path_builder { sibling_directory('config') }

  require_files path_builder { sibling_directory('lib') }
  require_files path_builder { sibling_directory('lib').child_directory('models') }
  require_files path_builder { sibling_directory('db') }
end

ENV['PATH'] = "D:\\oracle\\instantclient_11_2;#{ENV['PATH']}"
ENV['NLS_LANG'] = 'AMERICAN_CIS.CL8MSWIN1251'
ENV['ENV'] ||= 'production'
# ENV['ENV'] ||= 'development'

# logger_level = Logger::DEBUG
logger_level = Logger::INFO

# Загружаем файл настройки соединения с БД
dbconfig = YAML::load(File.open(File.join(File.dirname(__FILE__), 'database.yml')))

if ENV['ENV'] == 'development'
  dbconfig[ENV['ENV']]['database'] = '../' + dbconfig[ENV['ENV']]['database'] unless File.exist? dbconfig[ENV['ENV']]['database']
end

# Ошибки работы с БД направим в стандартный поток (консоль)
ActiveRecord::Base.logger = Logger.new(File.expand_path(File.join(File.dirname(__FILE__), '../log/db.log'))) # Simple logging utility. logger.rb -- standart lib
ActiveRecord::Base.logger.level = logger_level

# Соединяемся с БД
ActiveRecord::Base.establish_connection(dbconfig[ENV['ENV']])

if File.exists? "log/#{ENV['ENV']}.log"
  log_file = File.open("log/#{ENV['ENV']}.log", 'a+')
else
  log_file = File.open("../log/#{ENV['ENV']}.log", 'a+')
end
$log = Logger.new MultiIO.new(STDOUT, log_file)
$log.level = logger_level
$log.formatter = proc do |severity, datetime, progname, msg|
  date_format = datetime.strftime('%d.%m.%Y %H:%M:%S')
  "[#{date_format}] #{severity}: #{msg}\n"
end
