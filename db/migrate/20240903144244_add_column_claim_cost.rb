# frozen_string_literal: true

class AddColumnClaimCost < ActiveRecord::Migration[6.1]
  def change
    add_column :raw_files, :claim_status, :string
    add_column :marketing_prices, :claim_status, :string
    add_column :internal_prices, :claim_status, :string
  end
end
