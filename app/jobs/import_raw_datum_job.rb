class ImportRawDatumJob < ApplicationJob
  queue_as :default

  def perform(datum, symptom_set, vax_set)
    RawDatum.import_datum!(datum, symptom_set, vax_set)
  end
end
