class AddTimestampsToDictionaries < ActiveRecord::Migration
  def change
    change_table(:dictionaries) { |t| t.timestamps nulls: false }
  end
end
