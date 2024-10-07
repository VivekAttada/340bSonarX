class ChangeProgramRevenueToDecimalInRawFiles < ActiveRecord::Migration[7.0]
  def up
    # Add an explicit cast to handle conversion from existing type to decimal
    execute <<-SQL
      ALTER TABLE raw_files
      ALTER COLUMN program_revenue
      TYPE decimal(10, 2) USING program_revenue::numeric(10, 2);
    SQL
  end

  def down
    # Revert column type back to string if needed
    change_column :raw_files, :program_revenue, :string
  end
end

