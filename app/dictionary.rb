module Dictionary
  require 'config'
  require 'record'

  class Model
    attr_accessor :objects

    def create_class(class_name, superclass)
      klass = Class.new superclass
      Object.const_set class_name, klass
    end

    def initialize(table)
      attrs = Array.new
      self.objects = Array.new

      table.each { |table_name, table_def|

        table_def[:fields].each { |key, value|
          attrs.push value['name'].to_sym
        }

        class_name = table_name.to_s.camelize

        obj = create_class(class_name, ActiveRecord::Base) do
          self.table_name = table_name
          self.send(:attr_accessor, *attrs)
        end

        eval "#{table_name} = #{class_name}.new" or puts "Class instantiation failed"

        self.objects.append obj
      }
    end
  end
end