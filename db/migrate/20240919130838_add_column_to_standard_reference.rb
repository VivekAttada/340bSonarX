class AddColumnToStandardReference < ActiveRecord::Migration[7.0]
  def change
    add_column :standard_reference_prices, :health_system_name, :string
  end
end
