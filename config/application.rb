module SCParser
  class Application
    class << self
      attr_reader :properties

      ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

      def output_path
        path('output')
      end

      def dictionaries_path
        path('dictionaries')
      end

      def processed_path
        File.expand_path(File.join(dictionaries_path, 'processed'))
      end

      def load_file(load_path, filename)
        cpath = path("#{load_path}")
        file = File.expand_path(File.join(cpath, filename))
        @logger.debug "File #{filename} not exists" unless File.exist?(file)

        file
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

      def db_path
        path('db')
      end

      def tmp_path
        path('tmp')
      end

      def migration_path
        File.expand_path(File.join(db_path, 'migrate'))
      end

      def models_path
        File.expand_path(File.join(lib_path, 'models'))
      end

      def autoload_paths
        [lib_path, models_path].each do |path|
          $LOAD_PATH << path
          Dir[path + '/*.rb'].each { |file| require file }
        end
      end

      def dbconfig
        dbconfig = YAML::load(File.open(File.join(config_path, 'database.yml')))

        if dbconfig[ENV['ENV']]['adapter'] == 'sqlite3'
          dbconfig[ENV['ENV']]['database'] = File.expand_path(File.join(ROOT, dbconfig[ENV['ENV']]['database'])) unless File.exist? dbconfig[ENV['ENV']]['database']
        end

        dbconfig
      end

      def logger_level
        @logger = SCParser::ParserLogger.instance

        case ENV['ENV']
          when 'test'
            logger_level = Logger::DEBUG
          when 'development'
            logger_level = Logger::DEBUG
          when 'production'
            logger_level = Logger::INFO
          else
            logger_level = Logger::DEBUG
            @logger.abort "Unknown environment"
            exit 42
        end

        logger_level
      end

      def size(count)
        case count
          when 0
            mod = 0
            @logger.fatal "No data"
          when 1 .. 10 then
            mod = 1
          when 11 .. 1000 then
            mod = 5
          when 1001 .. 10000 then
            mod = 100
          when 10001 .. 50000 then
            mod = 500
          when 50001 .. 100000 then
            mod = 10000
          else
            mod = 20000
        end

        mod
      end

      def dbconnect
        ActiveRecord::Base.logger = Logger.new(File.expand_path(File.join(log_path, 'db.log')))
        ActiveRecord::Base.logger.level = logger_level
        ActiveRecord::Base.logger.formatter = proc do |severity, datetime, progname, msg|
          date_format = datetime.strftime('%d.%m.%Y %H:%M:%S')
          "[#{date_format}] #{severity}: #{msg}\n"
        end

        ActiveRecord::Base.logger.info
        ActiveRecord::Base.logger.info '======================== Log opened ========================'

        ActiveRecord::Base.establish_connection(dbconfig[ENV['ENV']])
      end

      def initialize!
        raise "Application has been already initialized." if @initialized
        autoload_paths
        dbconnect
        @properties = {
            output_path: output_path,
            processed_path: processed_path,
            config_path: config_path,
            log_path: log_path,
            db_path: db_path,
            tmp_path: tmp_path,
            migration_path: migration_path,
            models_path: models_path,
            logger_level: logger_level,
            dictionaries_path: dictionaries_path
        }
        @initialized = true
        self
      end

      private
      def path(folder)
        File.expand_path(File.join(ROOT, folder))
      end
    end
  end
end