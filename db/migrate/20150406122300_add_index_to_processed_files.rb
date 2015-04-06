class AddIndexToProcessedFiles < ActiveRecord::Migration
  def change
    add_index :processed_files, :file_name, :unique => true
  end
end
