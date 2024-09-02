# frozen_string_literal: true

class CreateMarketingPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :marketing_prices do |t|
      t.string :ndc
      t.string :bin
      t.string :pcn
      t.string :group
      t.string :state
      t.float :claim_cost
      t.float :quantity_dispensed
      t.boolean :matched_status, default: false
      t.string :health_system_name

      t.timestamps
    end
  end
end
