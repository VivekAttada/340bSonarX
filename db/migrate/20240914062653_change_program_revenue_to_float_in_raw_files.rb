class ChangeProgramRevenueToFloatInRawFiles < ActiveRecord::Migration[7.0]
  def change
    change_column :raw_files, :program_revenue, :float
    change_column :awp_prices, :awp_price, :float
  end
end
