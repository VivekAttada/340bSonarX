class AddMatchedStatusColumnToStandardReferencePrice < ActiveRecord::Migration[7.0]
  def change
    add_column :standard_reference_prices, :matched_status, :boolean, default: false
  end
end
