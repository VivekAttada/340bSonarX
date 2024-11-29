# frozen_string_literal: true

class CreateAwpPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :awp_prices do |t|
      t.string :ndc
      t.string :awp_price
      t.string :package_size_quantity
      t.string :awp_per_package
      t.timestamps
    end
  end
end
