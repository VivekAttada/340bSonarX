# frozen_string_literal: true

class CreateAwpPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :awp_prices do |t|
      t.string  :ndc
      t.string  :awp
      t.string  :fdb_package_size_quantity
      t.string  :awp_per_package
      t.string  :product_description
      t.string  :abbreviated_desc
      t.datetime :awp_date
      t.string  :bu_per_package
      t.string  :fdb_awp_whole_sale_factor
      t.string  :fdb_case_pack

      t.timestamps
    end
  end
end
