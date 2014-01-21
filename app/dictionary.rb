module Dictionary
  require 'config'
  require 'record'

  class Model
    attr_accessor :objects

    def initialize(table)
      attrs = Array.new
      self.objects = Array.new

      table.each { |table_name, table_def|
        table_def[:fields].each { |key, value|
          attrs.push value['name'].to_sym
        }

        methods = Hash.new

        if table_def.has_key?(:fk)
          table_def[:fk].each { |key, value|
            methods[value[:table].to_s.downcase.sub(table_def[:dictionary].to_s + '_', '').to_sym] = value
          }
        end

        class_name = table_name.to_s.camelize

        klass = Class.new(ActiveRecord::Base) do
          table_name = table_name
          if table_def.has_key?(:fk)
            methods.each { |key, value|
              method_name = key
              define_method method_name do
                puts method_name
              end
            }
          end
        end

        obj = Object.const_set class_name, klass

        eval "#{table_name} = #{class_name}.new" or puts "Class instantiation failed"

        self.objects.append obj
      }
    end
  end
end