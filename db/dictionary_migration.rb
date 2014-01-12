class DictionaryMigration < ActiveRecord::Migration
  def self.up(table)
    create_table table['name'].to_s.to_sym unless ActiveRecord::Base.connection.table_exists?(table['name'].to_s.to_sym)
    table['fields'].each do |key, value|
      unless ActiveRecord::Base.connection.column_exists?(table['name'].to_s.to_sym, value['name'].to_s.to_sym, value['type'].to_s.to_sym)
        add_column table['name'].to_s.to_sym, value['name'].to_s.to_sym, value['type'].to_s.to_sym
      end
    end
  end

  def self.down(table)
    drop_table table['name'].to_s.to_sym
  end
end
