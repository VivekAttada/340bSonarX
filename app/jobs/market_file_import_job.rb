class MarketFileImportJob < ApplicationJob
  # queue_as :default

  def initialize(batch)
    @batch = batch
  end

  def perform
    MarketingPrice.import expected_headers, @batch
  end

  def expected_headers
   %w[ndc bin group state claim_cost quantity_dispensed health_system_name]
  end
end
