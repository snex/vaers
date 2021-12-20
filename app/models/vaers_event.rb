class VaersEvent < ApplicationRecord
  belongs_to :raw_datum

  has_many :vaccines

  def self.import_from_raw_datum!(raw_datum)
    return if raw_datum.vaers_event.present?

    transaction do
      new_event = create!(
        raw_datum:                raw_datum,
        state:                    raw_datum.state.try(:upcase),
        patient_age:              raw_datum.age_yrs.try(:to_d),
        sex:                      raw_datum.sex.try(:upcase),
        died:                     raw_datum.died == 'Y',
        date_died:                raw_datum.datedied && Date.strptime(raw_datum.datedied, '%m/%d/%Y'),
        life_threatening_illness: raw_datum.l_threat == 'Y',
        er_visit:                 raw_datum.er_visit == 'Y',
        hospitalized:             raw_datum.hospital == 'Y',
        days_hospitalized:        raw_datum.hospdays && raw_datum.hospdays.to_i,
        disability:               raw_datum.disable == 'Y',
        recovered:                raw_datum.recovd == 'Y',
        vaccinated_date:          raw_datum.vax_date && Date.strptime(raw_datum.vax_date, '%m/%d/%Y'),
        onset_date:               raw_datum.onset_date && Date.strptime(raw_datum.onset_date, '%m/%d/%Y'),
        birth_defect:             raw_datum.birth_defect == 'Y'
      )

      raw_datum.vaccines.each do |vaccine|
        Vaccine.create!(
          vaers_event:  new_event,
          vaccine_type: vaccine['vax_type'].try(:upcase),
          manufacturer: vaccine['vax_manu'].try(:upcase),
          lot:          vaccine['vax_lot'].try(:upcase),
          dose_series:  vaccine['vax_dose_series'].try(:upcase),
          route:        vaccine['vax_route'].try(:upcase),
          site:         vaccine['vax_site'].try(:upcase),
          name:         vaccine['vax_name'].try(:upcase)
        )
      end
    end
  end
end
