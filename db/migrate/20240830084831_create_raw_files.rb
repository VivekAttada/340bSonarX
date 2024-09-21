# frozen_string_literal: true

class CreateRawFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :raw_files do |t|
      t.string  :contract_pharmacy_name
      t.string  :ndc
      t.float   :program_revenue
      t.string  :dispensed_quantity
      t.string  :pharmacy_npi
      t.string  :health_system_name
      t.boolean :matched_status, default: false
      t.string  :paid_status
      t.string  :rx_file_provider_name
      t.integer :days_supply
      t.string  :transaction_code
      t.string  :card_holder
      t.string  :primary_bin
      t.string  :primary_pcn
      t.string  :primary_group
      t.string  :primary_payer_name
      t.string  :primary_plan_name
      t.string  :primary_plan_type
      t.string  :primary_benefit_plan_name
      t.date    :processed_date
      t.string  :three_forty_b_id
      t.string  :rx
      t.string  :drug_name
      t.string  :manufacturer
      t.string  :drug_class
      t.integer :packages_dispensed
      t.integer :mdq
      t.date    :rx_written_date
      t.date    :dispensed_date
      t.string  :fill
      t.integer :patient_paid
      t.integer :admin_fee
      t.integer :dispensing_fee
      t.string  :claim_status
      t.boolean :matched_ndc_bin_pcn_state,  default: false
      t.boolean :matched_ndc_bin_pcn,  default: false
      t.boolean :matched_ndc_bin,  default: false

      t.timestamps
    end
  end
end
