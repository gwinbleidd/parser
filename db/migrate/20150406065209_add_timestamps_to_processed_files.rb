class AddTimestampsToProcessedFiles < ActiveRecord::Migration
  def change
    change_table(:processed_files) { |t| t.timestamps }
  end
end
