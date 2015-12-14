class Upload
  def proceed
    fl = FileLoader.new

    fl.dictionaries.each do |c|
      conf = Configuration.new(c)

      $log.debug "Table: #{conf.table}" unless conf.table.nil?
      $log.debug "Foreign keys: #{conf.foreign_keys}" unless conf.foreign_keys.nil?
      $log.debug "Key columns: #{conf.key_columns}" unless conf.key_columns.nil?
      $log.debug "Primary keys: #{conf.primary_keys}" unless conf.primary_keys.empty?
      $log.debug "Input config: #{conf.input_config}" unless conf.output_config.nil?
      $log.debug "Output config: #{conf.output_config}" unless conf.output_config.nil?

      dict = Record.new(conf)

      out = Hash.new

      dict.records.each do |key, value|
        $log.info("Starting creating output array of data for file #{key}")
        out[key] = Output.new(conf, Joined.new(conf, value).joined)
      end

      model = Model.new(conf.table[:dictionary])

      model.objects.each do |o|
        case fl.config[c]['type']
          when 'clear' then
            o.delete_all

            out.each_value do |file_content|
              found = inserted = i = 0

              file_content.records[:data].each_value do |v|
                i += 1

                o.create v
                inserted += 1

                if i == file_content.size
                  $log.info("#{o.to_s}: Processed #{i} of #{file_content.size} records, inserted #{inserted}, found #{found}")
                else
                  print "Processing #{i} of #{file_content.size} records\r" if i % file_content.mod == 0 or i == 1
                end
              end
            end

          when 'update' then
            out.each_value do |file_content|
              if conf.table[:keys].nil?
                $log.fatal("Key fields not set for #{o.table_name}")
                abort "Key fields not set for #{o.table_name}"
              end

              found = inserted = i = 0

              file_content.records[:data].each_value do |v|
                i += 1
                rec = nil

                search_fields = Hash.new

                conf.table[:keys].each do |key_field|
                  case key_field[:type]
                    when 'string'
                      search_fields[key_field[:name]] = v[key_field[:name]].to_s
                    when 'integer'
                      search_fields[key_field[:name]] = v[key_field[:name]].to_i
                    else
                      $log.fatal("Unknown primary key type for #{o.table_name}")
                      abort "Unknown primary key type for #{o.table_name}"
                  end
                end

                rec = o.find_by search_fields

                if rec.nil?
                  begin
                  o.create v
                  inserted += 1
                  rescue Exception => e
                    $log.fatal "Error in line #{i}"
                    $log.fatal e
                    exit 1
                  end
                else
                  rec.update v
                  found += 1
                end

                if i == file_content.size
                  $log.info("#{o.to_s}: Processed #{i} of #{file_content.size} records, inserted #{inserted}, found #{found}")
                else
                  print "Processing #{i} of #{file_content.size} records\r" if i % file_content.mod == 0 or i == 1
                end
              end
            end

          when 'append' then
            out.each_value do |file_content|
              found = inserted = i = 0

              file_content.records[:data].each_value do |v|
                i += 1

                o.create v
                inserted += 1

                if i == file_content.size
                  $log.info("#{o.to_s}: Processed #{i} of #{file_content.size} records, inserted #{inserted}, found #{found}")
                else
                  print "Processing #{i} of #{file_content.size} records\r" if i % file_content.mod == 0 or i == 1
                end
              end
            end

          when nil
            $log.fatal("Dictionary #{c} does not have type")
            abort "Dictionary #{c} does not have type"

          else
            $log.fatal("Unknown type #{fl.config[c]['type']} of dictionary #{c}")
            abort "Unknown type #{fl.config[c]['type']} of dictionary #{c}"
        end
      end

      out = OutputFile.new(conf)
      out.start(model)
    end

    fl.finalize
  end
end