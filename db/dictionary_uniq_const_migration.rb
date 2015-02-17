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

      if value.has_key?(:keys)
        keys = Array.new
        value[:keys].each do |key_column|
          keys.append key_column[:name]
        end
        if ActiveRecord::Base.connection.index_exists? key.to_s.pluralize.to_sym, keys, unique: true
          Dictionary.logger.debug " Index for #{keys} exists"
        else
          Dictionary.logger.debug " Index for #{keys} doesn\'t exists"
        end
        unless ActiveRecord::Base.connection.index_exists? key.to_s.pluralize.to_sym, keys, unique: true
          add_index key.to_s.pluralize.to_sym, keys, unique: true
        end
      end
    end
  end

  def self.down(table)
    table.each do |key, value|
      if value.has_key?(:pk)
        remove_index key.to_s.pluralize.to_sym, value[:pk][:name]
      end

      if value.has_key?(:keys)
        keys = Array.new
        value[:keys].each do |k, v|
          v.each do |key_column|
            keys.append key_column[:name]
          end
        end

        remove_index key.to_s.pluralize.to_sym, keys, unique: true
      end
    end
  end
end