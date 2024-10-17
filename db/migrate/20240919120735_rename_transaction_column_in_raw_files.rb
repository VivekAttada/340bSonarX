class RenameTransactionColumnInRawFiles < ActiveRecord::Migration[7.0]
  def change
    rename_column :raw_files, :transaction, :transaction_code
  end
end

