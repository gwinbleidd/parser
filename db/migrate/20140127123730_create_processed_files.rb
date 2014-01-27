class CreateProcessedFiles < ActiveRecord::Migration
  def change
    create_table :processed_files do |t|
      t.string :file_name
      t.string :file_md5
    end
  end
end