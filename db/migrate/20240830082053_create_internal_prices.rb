# frozen_string_literal: true

class CreateInternalPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :internal_prices do |t|
      t.string :ndc
      t.string :bin
      t.string :pcn
      t.string :group
      t.string :state
      t.float :reimbursement_total
      t.float :quantity_dispensed
      t.datetime :transaction_date
      t.boolean :matched_status, default: false
      t.string :health_system_name

      t.timestamps
    end
  end
end
