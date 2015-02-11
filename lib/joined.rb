module Dictionary
  class Joined
    attr_reader :joined

    def initialize(config, records)
      output = Hash.new

      @name = config.name
      config.config['dictionaries'].each do |dictionary, props|
        @main = dictionary if props['main']
      end

      raise("No main table set for #{config.name}") if @main.nil?

      fk = Array.new
      config.foreign_keys[@main.to_s].each { |name, desc| fk.append desc[:column] }

      output[:data] = Hash.new

      records[@main.pluralize.to_sym].each do |id, data|
        output[:data][id] = Hash.new

        data.each do |cname, cvalue|
          if fk.index(cname).nil?
            output[:data][id][cname] = cvalue
          else
            fkey = nil

            config.foreign_keys[@main.to_s].each do |fkname, fkdata|
              fkey = fkname if fkdata[:column] == cname
            end

            fcolumn = config.foreign_keys[@main.to_s][fkey][:return]
            ftable = config.foreign_keys[@main.to_s][fkey][:table]
            fref = config.foreign_keys[@main.to_s][fkey][:column_ref]

            records[ftable.to_s.pluralize.to_sym].each do |fid, fdata|
              output[:data][id][fcolumn] = fdata[fcolumn] if fdata[fref].to_i == cvalue.to_i
            end
          end
        end
      end

      @joined = output
    end
  end
end