# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_12_19_022249) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "raw_data", force: :cascade do |t|
    t.string "vaers_id", null: false
    t.string "recvdate"
    t.string "state"
    t.string "age_yrs"
    t.string "cage_yr"
    t.string "cage_mo"
    t.string "sex"
    t.string "rpt_date"
    t.string "symptom_text"
    t.string "died"
    t.string "datedied"
    t.string "l_threat"
    t.string "er_visit"
    t.string "hospital"
    t.string "hospdays"
    t.string "x_stay"
    t.string "disable"
    t.string "recovd"
    t.string "vax_date"
    t.string "onset_date"
    t.string "numdays"
    t.string "lab_data"
    t.string "v_adminby"
    t.string "v_fundby"
    t.string "other_meds"
    t.string "cur_ill"
    t.string "history"
    t.string "prior_vax"
    t.string "splttype"
    t.string "form_vers"
    t.string "todays_date"
    t.string "birth_defect"
    t.string "ofc_visit"
    t.string "er_ed_visit"
    t.string "allergies"
    t.json "symptoms"
    t.json "vaccines"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["vaers_id"], name: "index_raw_data_on_vaers_id", unique: true
  end

  create_table "vaccines", force: :cascade do |t|
    t.string "vaccine_type"
    t.string "manufacturer"
    t.string "lot"
    t.string "dose_series"
    t.string "route"
    t.string "site"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "vaers_event_id"
    t.index ["vaers_event_id"], name: "index_vaccines_on_vaers_event_id"
  end

  create_table "vaers_events", force: :cascade do |t|
    t.string "state"
    t.decimal "patient_age"
    t.string "sex"
    t.boolean "died"
    t.date "date_died"
    t.boolean "life_threatening_illness"
    t.boolean "er_visit"
    t.boolean "hospitalized"
    t.integer "days_hospitalized"
    t.boolean "disability"
    t.boolean "recovered"
    t.date "vaccinated_date"
    t.date "onset_date"
    t.boolean "birth_defect"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "raw_datum_id"
    t.index ["raw_datum_id"], name: "index_vaers_events_on_raw_datum_id"
  end

  add_foreign_key "vaccines", "vaers_events"
  add_foreign_key "vaers_events", "raw_data"
end
