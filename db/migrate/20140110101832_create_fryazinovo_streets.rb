class CreateFryazinovoStreets < ActiveRecord::Migration
  def change
    create_table :fryazinovo_streets do |t|
      t.string :streetId
      t.string :streetName

      t.timestamps
    end
  end
end
