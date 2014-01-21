require 'dictionary'

module Dictionary
  class OutputFile
    attr :output
    def initialize(table)
      mdls = Dictionary::Model.new(table)

      mdls.main_view.all.each { |record|

      }
    end
  end
end