require 'model'

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
      else
        @sep = nil
      end
    end

    def start(mdls)
      File.open(@output_file, "w") do |csv|
        i = 0

        mdls.objects.each do |dict|
          dict.all.nil? ? size = 0 : size = dict.all.size

          case size
            when 0 then
              raise "No data for #{dict.to_s}"
            when 1 .. 10 then
              mod = 1
            when 11 .. 1000 then
              mod = 5
            when 1001 .. 10000 then
              mod = 100
            when 10001 .. 50000 then
              mod = 500
            else
              mod = 1000
          end

          dict.all.each do |rec|
            record = Hash.new
            @config.output_config['fields'].each { |key, value|
              if value['from'] == 'id'
                record[value['name'].to_sym] = eval('rec.' + value['from'].to_s).to_i.to_s
              else
                if value.has_key?('type')
                  record[value['name'].to_sym] = eval('rec.' + value['name'].to_s).to_i.to_s if value['type'] == 'number'
                  record[value['name'].to_sym] = eval('rec.' + value['name'].to_s).to_f.to_s if value['type'] == 'currency'
                  record[value['name'].to_sym] = eval('rec.' + value['name'].to_s).to_f.to_s if value['type'] == 'float'
                else
                  record[value['name'].to_sym] = eval('rec.' + value['name'].to_s).to_s.strip.encode(@config.output_config['file']['encoding'])
                end
              end
            }

            if i == 0
              csv.write header(record)
              csv.write to_csv record
            else
              csv.write to_csv record
            end

            i+=1

            if i == size
              Dictionary.logger.info("#{dict.to_s}: Outputed #{i} of #{size} records")
            else
              print "Outputed #{i} of #{size} records\r" if i % mod == 0 or i == 1
            end
          end
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