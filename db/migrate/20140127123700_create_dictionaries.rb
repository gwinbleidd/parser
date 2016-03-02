class CreateDictionaries < ActiveRecord::Migration
  def change
    create_table :dictionaries do |t|
      t.string :name
      t.text :config
      t.string :config_md5
      t.timestamps :null => false
    end
  end
end