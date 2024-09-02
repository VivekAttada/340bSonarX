# frozen_string_literal: true

class InternalFileImportJob
  def initialize(batch)
    @batch = batch
  end

  def perform
    return unless @batch.present?

    InternalPrice.import_data(expected_headers, @batch)
  end

  private

  def expected_headers
    %w[ndc bin pcn group state reimbursement_total quantity_dispensed transaction_date health_system_name]
  end
end
