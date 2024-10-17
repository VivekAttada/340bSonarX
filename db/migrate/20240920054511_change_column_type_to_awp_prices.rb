class ChangeColumnTypeToAwpPrices < ActiveRecord::Migration[7.0]
  def up
    change_column :awp_prices, :awp, :string
  end

  def down
    change_column :awp_prices, :awp, :float # Assuming the original data type was float
  end
end
