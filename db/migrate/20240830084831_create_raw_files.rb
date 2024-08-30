class CreateRawFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :raw_files do |t|
      t.string :contract_pharmacy_name
      t.string :ndc
      t.string :program_revenue
      t.string :quantity
      t.string :pharmacy_npi
      t.string :health_system_name
      t.boolean :matched_status
      t.string :paid_status
      t.string :rx_file_provider_name

      t.timestamps
    end
  end
end
