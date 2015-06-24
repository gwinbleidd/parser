class AddNameToProcessedFiles < ActiveRecord::Migration
  def change
    add_column :processed_files, :name, :text
  end
end