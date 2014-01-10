class CreateFryazinovoCities < ActiveRecord::Migration
  def change
    create_table :fryazinovo_cities do |t|
      t.string :cityId
      t.string :cityName

      t.timestamps
    end
  end
end
