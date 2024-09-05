# frozen_string_literal: true

class RawFileImportJob
  def initialize(batch)
    @batch = batch
  end

  def perform
    return unless @batch.present?

    RawFile.import_data(expected_headers, @batch)
  end

  private

  def expected_headers
    %w[contract_pharmacy_name ndc program_revenue quantity pharmacy_npi rx_file_provider_name health_system_name]
  end
end