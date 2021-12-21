class ImportCsvChunkJob < ApplicationJob
  queue_as :default

  def perform(base_filename, chunk_start, chunk_size)
    RawDatum.import_csv_chunk(base_filename, chunk_start, chunk_size)
  end
end
