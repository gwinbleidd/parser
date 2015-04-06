class AddIndexToProcessedFiles < ActiveRecord::Migration
  def change
    add_index :processed_files, :file_name, :unique => true
    add_index :processed_files, :file_md5, :unique => true
  end
end
