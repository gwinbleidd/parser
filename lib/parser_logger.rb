require 'singleton'

module SCParser
  class ParserLogger < Logger
    include Singleton

    def initialize
      log_path = File.join(File.expand_path(File.join(File.dirname(__FILE__), '..', 'log')), "#{ENV['ENV']}.log")

      log_file = File.open(log_path, 'a+')

      super(MultiIO.new(STDOUT, log_file))

      self.level = logger_level

      self.formatter = proc do |severity, datetime, progname, msg|
        date_format = datetime.strftime('%d.%m.%Y %H:%M:%S')
        "[#{date_format}] #{severity}: #{msg}\n"
      end
    end

    def abort(message)
      self.fatal message
      exit 1
    end

    private
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
  end
end