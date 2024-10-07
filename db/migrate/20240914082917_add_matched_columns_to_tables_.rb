class AddMatchedColumnsToTables < ActiveRecord::Migration[7.0]
  def change
    add_column :internal_prices, :matched_ndc_bin_pcn_state, :boolean
    add_column :internal_prices, :matched_ndc_bin_pcn, :boolean
    add_column :internal_prices, :matched_ndc_bin, :boolean
    add_column :raw_files, :matched_ndc_bin_pcn_state, :boolean
    add_column :raw_files, :matched_ndc_bin_pcn, :boolean
    add_column :raw_files, :matched_ndc_bin, :boolean
    add_column :marketing_prices, :matched_ndc_bin_pcn_state, :boolean
    add_column :marketing_prices, :matched_ndc_bin_pcn, :boolean
    add_column :marketing_prices, :matched_ndc_bin, :boolean
  end
end
