# frozen_string_literal: true

class StandardReferencePriceImportJob
  include Sidekiq::Worker

  def perform(batch, health_system_name)
    return unless batch.present?

    StandardReferencePrice.import_data(expected_headers, batch, health_system_name)
  end

  private

  def expected_headers
    %w[ndc awp package_size awp_per_package_size reimbursement_per_quantity_dispensed]
  end
end
