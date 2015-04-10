class AddIndexOnMd5ToDictionaries < ActiveRecord::Migration
  def change
    add_index :dictionaries, :input_config_md5
    add_index :dictionaries, :output_config_md5
  end
end
