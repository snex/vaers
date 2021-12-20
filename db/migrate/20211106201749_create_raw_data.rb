class CreateRawData < ActiveRecord::Migration[6.1]
  def change
    create_table :raw_data do |t|
      t.string :vaers_id, null: false
      t.string :recvdate
      t.string :state
      t.string :age_yrs
      t.string :cage_yr
      t.string :cage_mo
      t.string :sex
      t.string :rpt_date
      t.string :symptom_text
      t.string :died
      t.string :datedied
      t.string :l_threat
      t.string :er_visit
      t.string :hospital
      t.string :hospdays
      t.string :x_stay
      t.string :disable
      t.string :recovd
      t.string :vax_date
      t.string :onset_date
      t.string :numdays
      t.string :lab_data
      t.string :v_adminby
      t.string :v_fundby
      t.string :other_meds
      t.string :cur_ill
      t.string :history
      t.string :prior_vax
      t.string :splttype
      t.string :form_vers
      t.string :todays_date
      t.string :birth_defect
      t.string :ofc_visit
      t.string :er_ed_visit
      t.string :allergies
      t.json   :symptoms
      t.json   :vaccines

      t.timestamps
    end

    add_index :raw_data, :vaers_id, unique: true
  end
end
