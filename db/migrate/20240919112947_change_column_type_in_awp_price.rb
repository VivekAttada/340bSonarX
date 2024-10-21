class ChangeColumnTypeInAwpPrice < ActiveRecord::Migration[7.0]
  def up
    change_column :awp_prices, :awp_date, :datetime
  end

  def down
    change_column :awp_prices, :awp_date, :date
  end
end
