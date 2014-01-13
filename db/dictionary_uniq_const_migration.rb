class DictionaryUniqConstMigration < ActiveRecord::Migration
  def self.up(table)
    add_index table['name'].to_sym, table['pk']['column'].to_sym, unique: true
  end

  def self.down(table)
    remove_index table['name'].to_sym, table['pk']['column'].to_sym
  end
end