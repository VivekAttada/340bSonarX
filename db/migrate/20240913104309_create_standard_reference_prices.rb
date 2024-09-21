class CreateStandardReferencePrices < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_reference_prices do |t|
      t.string  :ndc
      t.float   :awp
      t.string  :package_size
      t.float   :awp_per_package_size
      t.float   :reimbursement_per_quantity_dispensed
      t.string  :health_system_name
      t.boolean :matched_status, default: false

      t.timestamps
    end
  end
end
