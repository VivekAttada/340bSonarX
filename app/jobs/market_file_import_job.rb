# frozen_string_literal: true

class MarketFileImportJob
  def initialize(batch)
    @batch = batch
  end

  def perform
    return unless @batch.present?

    MarketingPrice.import_data(expected_headers, @batch)
  end

  private

  def expected_headers
    %w[ndc bin pcn group state claim_cost quantity_dispensed health_system_name]
  end
end
