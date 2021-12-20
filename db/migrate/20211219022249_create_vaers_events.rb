class CreateVaersEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :vaers_events do |t|
      t.string  :state
      t.numeric :patient_age
      t.string  :sex
      t.boolean :died
      t.date    :date_died
      t.boolean :life_threatening_illness
      t.boolean :er_visit
      t.boolean :hospitalized
      t.integer :days_hospitalized
      t.boolean :disability
      t.boolean :recovered
      t.date    :vaccinated_date
      t.date    :onset_date
      t.boolean :birth_defect

      t.timestamps
    end

    add_reference :vaers_events, :raw_datum, foreign_key: true

    create_table :vaccines do |t|
      t.string  :vaccine_type
      t.string  :manufacturer
      t.string  :lot
      t.string  :dose_series
      t.string  :route
      t.string  :site
      t.string  :name

      t.timestamps
    end

    add_reference :vaccines, :vaers_event, foreign_key: true
  end
end
