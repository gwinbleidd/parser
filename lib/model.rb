require 'config_file'
require 'configuration'

class Model
  attr_reader :config, :name, :objects

  def initialize(dict_name)
    @log = ParserLogger.instance
    cf = ConfigFile.new
    @name = dict_name
    @config = Configuration.new(@name)

    attrs = Array.new
    @objects = Array.new

    @config.table[:fields].each { |field_name, field_def|
      attrs.push field_def['name'].to_sym
    }

    class_name = @name.to_s.camelize

    klass = Class.new(ActiveRecord::Base) do
      table_name = @name
    end

    obj = Object.const_set class_name, klass

    eval "#{@name} = #{class_name}.new" or @log.abort "Class instantiation failed"

    @objects.append obj
  end
end