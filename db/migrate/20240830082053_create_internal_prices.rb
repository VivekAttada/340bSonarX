# frozen_string_literal: true

class CreateInternalPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :internal_prices do |t|
      t.string  :ndc
      t.string  :bin
      t.string  :pcn
      t.string  :group
      t.string  :state
      t.float   :reimbursement_total
      t.float   :quantity_dispensed
      t.datetime :transaction_date
      t.boolean :matched_status, default: false
      t.string  :health_system_name
      t.string  :paid_status
      t.string  :claim_status
      t.boolean :matched_ndc_bin_pcn_state, default: false
      t.boolean :matched_ndc_bin_pcn, default: false
      t.boolean :matched_ndc_bin, default: false

      t.timestamps
    end
  end
end
