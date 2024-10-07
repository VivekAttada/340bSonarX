# frozen_string_literal: true

class AddPaidStatusToMultipleTables < ActiveRecord::Migration[6.1]
  def change
    add_column :internal_prices, :paid_status, :string
    add_column :marketing_prices, :paid_status, :string
  end
end
