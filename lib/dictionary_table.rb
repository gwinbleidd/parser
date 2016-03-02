module SCParser
  class DictionaryTable
    attr_reader :object

    def initialize(params)
      log = ParserLogger.instance
      name = params[:name]
      # table = params[:properties][:table]

      class_name = name.to_s.camelize

      klass = Class.new(ActiveRecord::Base) do
        self.table_name = name
      end

      Object.send(:remove_const, class_name.to_sym) if Object.const_defined?(class_name)

      @object = Object.const_set class_name, klass

      eval "#{name} = #{class_name}.new" or log.abort "Class instantiation failed for dictionary #{name}"
    end
  end
end