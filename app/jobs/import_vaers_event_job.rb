class ImportVaersEventJob < ApplicationJob
  queue_as :default

  def perform(raw_datum)
    VaersEvent.import_from_raw_datum!(raw_datum)
  end
end
