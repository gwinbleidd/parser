class DictionaryUniqConstMigration < ActiveRecord::Migration
  def self.up(table)
    $log.debug "Creating unique index for #{table[:name]}"
    if table.has_key?(:pk)
      if ActiveRecord::Base.connection.index_exists? table[:name], table[:pk], unique: true
        $log.debug " Index for #{table[:pk][:name]} exists"
      else
        $log.debug " Index for #{table[:pk][:name]} doesn\'t exists"
      end
      unless ActiveRecord::Base.connection.index_exists? table[:name], table[:pk], unique: true
        add_index table[:name], table[:pk][:name], unique: true
      end
    end

    if table.has_key?(:keys)
      keys = Array.new
      table[:keys].each do |key_column|
        keys.append key_column[:name]
      end
      if ActiveRecord::Base.connection.index_exists? table[:name], keys, unique: true
        $log.debug " Index for #{keys} exists"
      else
        $log.debug " Index for #{keys} doesn\'t exists"
      end
      unless ActiveRecord::Base.connection.index_exists? table[:name], keys, unique: true
        add_index table[:name], keys, unique: true
      end
    end
  end

  def self.down(table)
    if table.has_key?(:pk)
      remove_index table[:name], table[:pk][:name]
    end

    if table.has_key?(:keys)
      keys = Array.new
      table[:keys].each do |k, v|
        v.each do |key_column|
          keys.append key_column[:name]
        end
      end

      remove_index table[:name], keys, unique: true
    end
  end
end