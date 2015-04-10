class DictionaryTableMigration < ActiveRecord::Migration
  def self.up(name, fields)
    unless ActiveRecord::Base.connection.table_exists?(name.to_s.to_sym)
      Logger.logger.debug "Creating table #{name.to_s.to_sym}, #{fields}"
      create_table name.to_s.to_sym

      fields.each do |key, value|
        Logger.logger.debug " Adding column #{value['name'].to_s.to_sym}: #{value['type'].to_s.to_sym}"
        unless ActiveRecord::Base.connection.column_exists?(name.to_s.to_sym, value['name'].to_s.to_sym, value['type'].to_s.to_sym)
          add_column name.to_s.to_sym, value['name'].to_s.to_sym, value['type'].to_s.to_sym
        end
      end

      change_table(name.to_s.to_sym) { |t| t.timestamps }
    end
  end

  def self.down(name, fields)
    drop_table name
  end
end
