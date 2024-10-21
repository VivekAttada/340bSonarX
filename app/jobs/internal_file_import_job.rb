# frozen_string_literal: true
class InternalFileImportJob
  include Sidekiq::Worker

  def perform(batch, health_system_name)
    return unless batch.present?

    InternalPrice.import_data(expected_headers, batch, health_system_name)
  end

  private

  def expected_headers
    %w[ndc bin pcn group state reimbursement_total quantity_dispensed reimbursement_per_quantity_dispensed transaction_date]
  end

  def batch_complete?(batch)
    batch.size == 10000
  end
end
