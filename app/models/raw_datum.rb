require 'csv'
require 'digest/md5'

class RawDatum < ApplicationRecord
  has_one :vaers_event

  # VAERS data comes in 3 CSV files per dataset
  # The files are named thusly:
  #   1. [base_filename]VAERSDATA.csv
  #   2. [base_filename]VAERSSYMPTOMS.csv
  #   3. [base_filename]VAERSVAX.csv
  # Just place them in the data/ folder and then
  # call this method on [base_filename] to import
  # the raw data
  #
  # This method is idempotent
  def self.import_from_csv(base_filename)
    data         = CSV.read("data/#{base_filename}VAERSDATA.csv",     headers: true, header_converters: lambda { |h| h.downcase }, encoding: 'iso-8859-1:utf-8')
    symptom_data = CSV.read("data/#{base_filename}VAERSSYMPTOMS.csv", headers: true, header_converters: lambda { |h| h.downcase }, encoding: 'iso-8859-1:utf-8')
    vax_data     = CSV.read("data/#{base_filename}VAERSVAX.csv",      headers: true, header_converters: lambda { |h| h.downcase }, encoding: 'iso-8859-1:utf-8')

    data.each do |datum|
      vaers_id = datum['vaers_id']
      symptom_set = symptom_data.select { |s| s['vaers_id'] == vaers_id }.map(&:to_h)
      vax_set = vax_data.select { |v| v['vaers_id'] == vaers_id }.map(&:to_h)
      ImportRawDatumJob.perform_later(datum.to_h, symptom_set, vax_set)
    end
  end

  def self.import_datum!(datum, symptom_set, vax_set)
    import_time = DateTime.now

    vaers_id = datum['vaers_id']
    return if RawDatum.where(vaers_id: vaers_id).exists?

    symptoms = []
    symptom_set.each do |ss|
      1.upto(5) do |i|
        symptom_n = ss["symptom#{i}"]
        symptom_version_n = ss["symptomversion#{i}"]
        symptoms.push(
          {
            'symptom'         => symptom_n,
            'symptom_version' => symptom_version_n
          }
        ) if symptom_n.present?
      end
    end

    datum['symptoms'] = symptoms
    datum['vaccines'] = vax_set
    new_raw_datum = create!(datum)
    ImportVaersEventJob.perform_later(new_raw_datum)
  end
end
