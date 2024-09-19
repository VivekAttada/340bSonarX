class RenameTwoColumnsInAwpPrice < ActiveRecord::Migration[7.0]
  def change
    rename_column :awp_prices, :package_size_quantity, :fdb_package_size_quantity
    rename_column :awp_prices, :awp_price, :awp
    rename_column :awp_prices, :fdb_awp_whole_sale_factor, :fdb_awp_wholesale_factor
    rename_column :raw_files, :transaction, :transaction_code
  end
end
