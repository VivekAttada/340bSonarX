class AddColumnsToAllTables < ActiveRecord::Migration[7.0]
  def change
    add_column :internal_prices, :reimbursement_per_quantity_dispensed, :float

    add_column :marketing_prices, :zip_code, :string
    add_column :marketing_prices, :reimbursement_per_quantity_dispensed, :float

    add_column :awp_prices, :product_description, :string
    add_column :awp_prices, :abbreviated_desc, :string
    add_column :awp_prices, :awp_date, :date
    add_column :awp_prices, :bu_per_package, :string
    add_column :awp_prices, :fdb_awp_whole_sale_factor, :string
    add_column :awp_prices, :fdb_case_pack, :string

    add_column :raw_files, :processed_date, :date
    add_column :raw_files, :three_forty_b_id, :string
    add_column :raw_files, :rx, :string
    add_column :raw_files, :drug_name, :string
    add_column :raw_files, :manufacturer, :string
    add_column :raw_files, :drug_class, :string
    add_column :raw_files, :packages_dispensed, :integer
    add_column :raw_files, :mdq, :integer
    add_column :raw_files, :rx_written_date, :date
    add_column :raw_files, :dispensed_date, :date
    add_column :raw_files, :fill, :string
    add_column :raw_files, :patient_paid, :integer
    add_column :raw_files, :admin_fee, :integer
    add_column :raw_files, :dispensing_fee, :integer
  end
end
