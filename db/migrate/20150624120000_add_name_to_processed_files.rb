class AddNameToProcessedFiles < ActiveRecord::Migration
  def change
    add_column :processed_files, :name, :string
  end
end