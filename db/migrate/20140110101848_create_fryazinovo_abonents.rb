class CreateFryazinovoAbonents < ActiveRecord::Migration
  def change
    create_table :fryazinovo_abonents do |t|
      t.string :accountNr
      t.string :lastName
      t.string :firstName
      t.string :secondName
      t.string :cityId
      t.string :streetId
      t.string :houseNr
      t.string :flatNr
      t.string :debtSum
      t.string :coldWater1
      t.string :coldWater2
      t.string :hotWater1
      t.string :hotWater2
      t.string :currAcc

      t.timestamps
    end
  end
end
