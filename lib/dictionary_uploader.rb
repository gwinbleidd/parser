require 'general_config'
module SCParser
  class DictionaryUploader
    def initialize(params)
      @log = ParserLogger.instance
      @file_size = params[:file_size]
      @table = params[:table]
      @name = params[:name]

      gf = SCParser::GeneralConfig.instance
      @type = gf.config[@name]['dictionary_type']
      dt = SCParser::DictionaryTable.new(name: @table[:name])

      @tbl = dt.object

      if @type == 'clear'
        # DictionaryTableMigration.down(params[:table][:name], params[:table][:fields])
        # DictionaryTableMigration.up(params[:table][:name], params[:table][:fields])
        # DictionaryUniqConstMigration.up(params[:table])
        @tbl.delete_all
      end

      @inserted = @updated = @processed = 0
    end

    def process(records)
      result = Hash.new
      case @type
        when 'clear'
          clear(records)

          @processed += records.size
        when 'update'
          update(records)

          @processed += records.size
        else
          @log.abort "Unknown type, dictionary: #{@name}, type: #{@type}"
      end
      result[:processed] = @processed
      result[:inserted] = @inserted
      result[:updated] = @updated

      result
    end

    private
    def clear(records)
      ActiveRecord::Base.transaction do
        # records.each_value do |record|
        #   @tbl.create record
        #
        # end

        @tbl.create records.values
        @inserted += records.size
      end
    end

    def update(records)
      if @table[:keys].nil?
        @log.abort "Key fields not set for #{@tbl.table_name}"
      end

      ActiveRecord::Base.transaction do
        records.each_value do |record|
          search_fields = Hash.new

          @table[:keys].each do |key_field|
            case key_field[:type]
              when 'string'
                search_fields[key_field[:name]] = record[key_field[:name]].to_s
              when 'integer'
                search_fields[key_field[:name]] = record[key_field[:name]].to_i
              else
                @log.abort "Unknown primary key type for #{o.table_name}"
            end
          end

          rec = @tbl.find_by search_fields
          if rec.nil?
            begin
              @tbl.create record
              @inserted += 1
            rescue Exception => e
              @log.fatal e
              @log.abort e.backtrace.join "\n"
            end
          else
            rec.update record
            @updated += 1
          end
        end
      end
    end
  end
end