# frozen_string_literal: true

class MarketFileImportJob
  include Sidekiq::Worker

  def perform(batch, health_system_name)
    return unless batch.present?

    MarketingPrice.import_data(expected_headers, batch, health_system_name)
  end

  private

  def expected_headers
    %w[ndc bin pcn group state claim_cost quantity_dispensed reimbursement_per_quantity_dispensed]
  end
end
