class CreateDictionaries < ActiveRecord::Migration
  def self.up
    create_table :dictionaries do |t|
      t.string :name
      t.text :config
      t.string :config_md5
    end
  end

  def self.down
    drop_table :dictionaries
  end
end