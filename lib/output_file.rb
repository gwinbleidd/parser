require 'dictionary'

module Dictionary
  class OutputFile
    def initialize(conf)
      Dictionary.logger.info("Starting create OutputFile for #{conf.name}")
      if conf.output_config['file'].has_key?('name') and conf.output_config['file'].has_key?('type')
        @output_file = File.expand_path "../output/#{conf.output_config['file']['name']}.#{conf.output_config['file']['type']}"
      else
        @output_file = nil
      end

      @config = conf

      if conf.output_config['file'].has_key?('name')
        @sep = conf.output_config['file']['delimiter']
      else @sep = nil
      end
    end

    def start(mdls)
      records = Array.new
      mdls.main_view.all.each do |rec|
        record = Hash.new
        @config.output_config['fields'].each { |key, value|
          if value['from'].is_a?(String)
            if value.has_key?('type')
              record[value['name'].to_sym] = eval('rec.' + value['from'].to_s).to_i.to_s if value['type'] == 'number'
              record[value['name'].to_sym] = eval('rec.' + value['from'].to_s).to_f.to_s if value['type'] == 'currency'
              record[value['name'].to_sym] = eval('rec.' + value['from'].to_s).to_f.to_s if value['type'] == 'float'
            else
              record[value['name'].to_sym] = eval('rec.' + value['from'].to_s).to_s.strip.encode(@config.output_config['file']['encoding'])
            end

            if value.has_key?('replace')
              value['replace'].each do |k,v|
                if eval('rec.' + value['from'].to_s).to_s.strip.encode(@config.output_config['file']['encoding']) == v.to_s.strip.encode(@config.output_config['file']['encoding'])
                  record[value['name'].to_sym] = k.to_s.strip.encode(@config.output_config['file']['encoding'])
                end
              end
            end
          elsif value['from'].is_a?(Array)
            fields = Array.new
            value['from'].each { |item| fields.push eval('rec.' + item).to_s.encode("UTF-8") }
            record[value['name'].to_sym] = fields.join("#{value['delimiter']}").to_s.strip.encode(@config.output_config['file']['encoding'])
          end
        }

        records.append record
      end

      File.open(@output_file, "w+") do |csv|
        csv.puts header(records.first)

        records.each do |record|
          csv.puts to_csv record
        end
      end
    end

    private
    def header(hash)
      hash.keys.join @sep unless hash.nil?
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