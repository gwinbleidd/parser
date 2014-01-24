require 'dictionary'

module Dictionary
  class OutputFile
    def initialize(conf)
      if conf.output_config['file'].has_key?('name') and conf.output_config['file'].has_key?('type')
        @output_file = File.expand_path "../dictionaries/" + "output/#{conf.output_config['file']['name']}.#{conf.output_config['file']['type']}"
      else
        @output_file = nil
      end

      @config = conf

      if conf.output_config['file'].has_key?('name')
        @sep = conf.output_config['file']['delimiter']
      else @sep = nil
      end
    end

    def start
      mdls = Dictionary::Model.new(@config.table)

      records = Array.new
      mdls.main_view.all.each { |rec|
        record = Hash.new
        @config.output_config['fields'].each { |key, value|
          if value['from'].is_a?(String)
            record[value['name'].to_sym] = eval('rec.' + value['from'].to_s).to_s.strip.encode(@config.output_config['file']['encoding'])
          elsif value['from'].is_a?(Array)
            fields = Array.new
            value['from'].each { |item| fields.push 'rec.' + item }
            record[value['name'].to_sym] = eval(fields.join "+\"#{value['delimiter']}\"+").to_s.strip.encode(@config.output_config['file']['encoding'])
          end
        }

        records.append record
      }

      File.open(@output_file, "w+") do |csv|
        csv.puts header(records.first)

        records.each do |record|
          csv.puts to_csv record
        end
      end
    end

    private
    def header(hash)
      hash.keys.join @sep
    end

    def to_csv(hash)
      hash.values.map do |value|
        escape value unless value.nil?
      end.join @sep
    end

    def escape(string)
      string.gsub(@sep, "")
    end
  end
end