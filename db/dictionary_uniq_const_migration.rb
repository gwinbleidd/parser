class DictionaryUniqConstMigration < ActiveRecord::Migration
  def self.up(table)
    table.each do |key, value|
      Dictionary.logger.debug "Creating unique index for #{key}"
      if value.has_key?(:pk)
        if ActiveRecord::Base.connection.index_exists? key.to_s.pluralize.to_sym, value[:pk], unique: true
          Dictionary.logger.debug " Index for #{value[:pk][:name]} exists"
        else
          Dictionary.logger.debug " Index for #{value[:pk][:name]} doesn\'t exists"
        end
        unless ActiveRecord::Base.connection.index_exists? key.to_s.pluralize.to_sym, value[:pk], unique: true
          add_index key.to_s.pluralize.to_sym, value[:pk][:name], unique: true
        end
      end
    end
  end

  def self.down(table)
    table.each do |key, value|
      if value.has_key?(:pk)
        remove_index key.to_s.pluralize.to_sym, value[:pk][:name]
      end
    end
  end
end