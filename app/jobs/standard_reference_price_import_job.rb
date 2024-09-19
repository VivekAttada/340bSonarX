# frozen_string_literal: true

class StandardReferencePriceImportJob
  include Sidekiq::Worker

  def perform(batch)
    return unless batch.present?

    StandardReferencePrice.import_data(expected_headers, batch)
  end

  private

  def expected_headers
    %w[ndc awp package_size awp_per_package_size reimbursement_per_quantity_dispensed health_system_name]
  end
end
