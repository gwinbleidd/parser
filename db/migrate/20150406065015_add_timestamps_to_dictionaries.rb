class AddTimestampsToDictionaries < ActiveRecord::Migration
  def change
    change_table(:dictionaries) { |t| t.timestamps }
  end
end
