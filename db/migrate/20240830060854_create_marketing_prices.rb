class CreateMarketingPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :marketing_prices do |t|
      t.string  :ndc
      t.string  :bin
      t.string  :pcn
      t.string  :group
      t.string  :state
      t.float   :claim_cost
      t.float   :quantity_dispensed
      t.boolean :matched_status, default: false
      t.string  :health_system_name
      t.string  :paid_status
      t.string  :zip_code
      t.string   :claim_status
      t.float   :reimbursement_per_quantity_dispensed
      t.boolean :matched_ndc_bin_pcn_state,  default: false
      t.boolean :matched_ndc_bin_pcn,  default: false
      t.boolean :matched_ndc_bin,  default: false

      t.timestamps
    end
  end
end
