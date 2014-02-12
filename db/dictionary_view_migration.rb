class DictionaryViewMigration < ActiveRecord::Migration
  def self.up(name, table)
    if table.has_key?(:main) and table[:main]
      flds = Array.new

      table[:fields].each { |k, v|
        flds.append "#{v['name'].to_s}"
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
        CREATE OR REPLACE FORCE VIEW v_#{table[:dictionary].to_s.pluralize} AS
        SELECT ID, #{flds.join ', '}
        FROM #{name} a
      SQL
    end
  end

  def self.down(name, table)
    execute <<-SQL
      DROP VIEW v_#{table[:dictionary].to_s.pluralize}
    SQL
  end
end