require 'singleton'

class Application
  class << self
    ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

    def output_path
      path('output')
    end

    def config_path
      path('config')
    end

    def log_path
      path('log')
    end

    def lib_path
      path('lib')
    end

    def models_path
      File.expand_path(File.join(lib_path, 'models'))
    end
	
	def db_path
	  path('db')
	end

    def autoload_paths
      [lib_path, models_path, db_path].each do |path|
        $LOAD_PATH << path
        Dir[path + '/*.rb'].each { |file| require file }
      end
    end

    def paths
      @paths ||= begin
        paths = Array.new

        paths.push ROOT
        paths.push path('app')
        paths.push path('bin')
        paths.push path('config')
        paths.push path('lib')
        paths.push path('lib\models')
        paths.push path('log')
        paths.push path('output')
      end
    end

    def logger_level
      case ENV['ENV']
        when 'development'
          logger_level = Logger::DEBUG
        when 'production'
          logger_level = Logger::INFO
        else
          logger_level = Logger::DEBUG
          abort "Unknown environment"
          exit 42
      end

      logger_level
    end

    def dbconfig
      dbconfig = YAML::load(File.open(File.join(config_path, 'database.yml')))

      if ENV['ENV'] == 'development' and dbconfig[ENV['ENV']]['adapter'] == 'sqlite3'
        dbconfig[ENV['ENV']]['database'] = File.expand_path(File.join(File.dirname(__FILE__), '../', dbconfig[ENV['ENV']]['database'])) unless File.exist? dbconfig[ENV['ENV']]['database']
      end

      dbconfig
    end

    def dbconnect
      ActiveRecord::Base.logger = Logger.new(File.expand_path(File.join(log_path, 'db.log')))
      ActiveRecord::Base.logger.level = logger_level
      ActiveRecord::Base.logger.formatter = proc do |severity, datetime, progname, msg|
        date_format = datetime.strftime('%d.%m.%Y %H:%M:%S')
        "[#{date_format}] #{severity}: #{msg}\n"
      end

      ActiveRecord::Base.establish_connection(dbconfig[ENV['ENV']])
    end

    def initialize!
      raise "Application has been already initialized." if @initialized
      autoload_paths
      dbconnect
      @initialized = true
      self
    end

    private
    def path(folder)
      File.expand_path(File.join(ROOT, folder))
    end
  end
end