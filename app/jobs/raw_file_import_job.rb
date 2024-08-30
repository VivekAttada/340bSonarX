class RawFileImportJob < ApplicationJob
  # queue_as :default

  def initialize(batch)
    @batch = batch
  end

  def perform
    RawFile.import expected_headers, @batch
  end

  def expected_headers
   %w[contract_pharmacy_name ndc pa_class program_revenue quantity pharmacy_npi health_system_name rx_file_provider_name]
  end
end
