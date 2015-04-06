class AddIndexToDictionaries < ActiveRecord::Migration
  def change
    add_index :dictionaries, :name, :unique => true
  end
end
