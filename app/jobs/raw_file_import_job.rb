# frozen_string_literal: true

class RawFileImportJob
  include Sidekiq::Worker

  def perform(batch)
    return unless batch.present?

    RawFile.import_data(expected_headers, batch)
  end

  private

  def expected_headers
    %w[contract_pharmacy_name ndc program_revenue quantity pharmacy_npi rx_file_provider_name
       processed_date three_forty_b_id rx drug_name manufacturer
       drug_class packages_dispensed mdq rx_written_date
       dispensed_date fill days_supply patient_paid admin_fee dispensing_fee health_system_name]
  end
end
