class ChangeAwpPriceToDecimalInAwpPrices < ActiveRecord::Migration[7.0]
  def up
    # Convert the column to decimal with appropriate precision and scale
    change_column :awp_prices, :awp_price, :decimal, precision: 10, scale: 2, using: 'awp_price::numeric'
  end

  def down
    # Rollback the change if needed
    change_column :awp_prices, :awp_price, :string
  end
end