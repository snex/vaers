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
    data_file = "data/#{base_filename}VAERSDATA.csv"
    headers_size = `head -n 1 #{data_file}`.size
    cursor = headers_size

    while chunk = IO.read(data_file, 1024*1024*10, cursor, encoding: 'iso-8859-1:utf-8') do
      chunk_size = chunk.rindex("\r\n")
      ImportCsvChunkJob.perform_later(base_filename, cursor, chunk_size)
      cursor += chunk_size + 2
    end
  end

  def self.import_csv_chunk(base_filename, chunk_start, chunk_size)
    data_headers    = `head -n 1 data/#{base_filename}VAERSDATA.csv`.chop.split(',').map(&:downcase)
    symptom_headers = `head -n 1 data/#{base_filename}VAERSSYMPTOMS.csv`.chop.split(',').map(&:downcase)
    vax_headers     = `head -n 1 data/#{base_filename}VAERSVAX.csv`.chop.split(',').map(&:downcase)

    chunk = IO.read("data/#{base_filename}VAERSDATA.csv", chunk_size, chunk_start, encoding: 'iso-8859-1:utf-8').force_encoding('ISO-8859-1')

    CSV.parse(chunk) do |row|
      datum = data_headers.zip(row).to_h
      vaers_id = datum['vaers_id']
      symptom_arr = `egrep '^#{vaers_id},' data/#{base_filename}VAERSSYMPTOMS.csv`.split("\r\n")
      symptom_set = symptom_arr.map { |symptoms| symptom_headers.zip(symptoms.split(',')) }.map(&:to_h)
      vax_arr = `egrep '^#{vaers_id},' data/#{base_filename}VAERSVAX.csv`.split("\r\n")
      vax_set = vax_arr.map { |vaxes| vax_headers.zip(vaxes.split(',')) }.map(&:to_h)

      ImportRawDatumJob.perform_later(datum, symptom_set, vax_set)
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
