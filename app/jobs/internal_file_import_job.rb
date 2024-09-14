# frozen_string_literal: true
class InternalFileImportJob
  include Sidekiq::Worker

  def perform(batch)
    return unless batch.present?

    InternalPrice.import_data(expected_headers, batch)
  end

  private

  def expected_headers
    %w[ndc bin pcn group state reimbursement_total quantity_dispensed reimbursement_per_quantity_dispensed health_system_name]
  end

  def batch_complete?(batch)
    batch.size == 10000
  end
end
