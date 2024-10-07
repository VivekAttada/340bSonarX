class AddMissingColumnsToRawFiles < ActiveRecord::Migration[7.0]
  def change
    rename_column :raw_files, :quantity, :dispensed_quantity
    add_column :raw_files, :days_supply, :integer
    add_column :raw_files, :transaction, :string
    add_column :raw_files, :card_holder, :string
    add_column :raw_files, :primary_bin, :string
    add_column :raw_files, :primary_pcn, :string
    add_column :raw_files, :primary_group, :string
    add_column :raw_files, :primary_payer_name, :string
    add_column :raw_files, :primary_plan_name, :string
    add_column :raw_files, :primary_plan_type, :string
    add_column :raw_files, :primary_benefit_plan_name, :string
  end
end
