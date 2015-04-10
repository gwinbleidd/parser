class RemoveColumnsFromDictionaries < ActiveRecord::Migration
  def change
    remove_column :dictionaries, :config
    remove_column :dictionaries, :config_md5
  end
end
