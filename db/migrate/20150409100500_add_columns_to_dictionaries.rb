class AddColumnsToDictionaries < ActiveRecord::Migration
  def change
    add_column :dictionaries, :input_config, :text
    add_column :dictionaries, :input_config_md5, :string
    add_column :dictionaries, :output_config, :text
    add_column :dictionaries, :output_config_md5, :string
  end
end
