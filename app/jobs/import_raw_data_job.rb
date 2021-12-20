class ImportRawDataJob < ApplicationJob
  queue_as :default

  def perform(base_filename)
    RawDatum.import_from_csv(base_filename)
  end
end
