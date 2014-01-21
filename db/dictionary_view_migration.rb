class DictionaryViewMigration < ActiveRecord::Migration
  def self.up(name, table)
    puts "\n #{name}"
    flds = Array.new

    table[:fields].each { |k, v|
      flds.append v['name'].to_s
    }

    if table.has_key?(:fk)
      table[:fk].each { |k, v|
        sql = "(SELECT #{v[:return]} "
        sql << "FROM #{v[:table].to_s.pluralize} t "
        sql << "WHERE t.#{v[:column_ref]} = a.#{v[:column]}) as #{v[:return]}"

        flds.append sql
      }
    end

    execute <<-SQL
      DROP VIEW IF EXISTS v_#{name}
    SQL

    execute <<-SQL
      CREATE VIEW v_#{name} AS
      SELECT #{flds.join ', '}
      FROM #{name} a
    SQL
  end

  def self.down(name, fields)
    execute <<-SQL
      DROP VIEW #{name}
    SQL
  end
end