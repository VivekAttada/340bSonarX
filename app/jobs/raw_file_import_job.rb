# frozen_string_literal: true

class RawFileImportJob
  include Sidekiq::Worker

  def perform(batch)
    return unless batch.present?

    RawFile.import_data(expected_headers, batch)
  end

  private

  def expected_headers
    %w[processed_date three_forty_b_id contract_pharmacy_name pharmacy_npi rx ndc drug_name
       manufacturer drug_class packages_dispensed mdq rx_written_date dispensed_date
       fill dispensed_quantity days_supply program_revenue patient_paid admin_fee
       dispensing_fee transaction_code card_holder primary_bin primary_pcn primary_group primary_payer_name
       primary_plan_name primary_plan_type primary_benefit_plan_name rx_file_provider_name health_system_name]
  end
end
