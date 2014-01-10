# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140110101848) do

  create_table "fryazinovo_abonents", force: true do |t|
    t.string   "accountNr"
    t.string   "lastName"
    t.string   "firstName"
    t.string   "secondName"
    t.string   "cityId"
    t.string   "streetId"
    t.string   "houseNr"
    t.string   "flatNr"
    t.string   "debtSum"
    t.string   "coldWater1"
    t.string   "coldWater2"
    t.string   "hotWater1"
    t.string   "hotWater2"
    t.string   "currAcc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fryazinovo_cities", force: true do |t|
    t.string   "cityId"
    t.string   "cityName"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fryazinovo_streets", force: true do |t|
    t.string   "streetId"
    t.string   "streetName"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
