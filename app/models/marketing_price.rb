class MarketingPrice < ApplicationRecord

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when '.csv' then Roo::CSV.new(file.path)
    when '.xls' then Roo::Excel.new(file.path)
    when '.xlsx' then Roo::Excelx.new(file.path)
    else
      raise "Unknown file type: #{file.original_filename}"
    end
  end

  def self.process_file(parsed_file)
    batch = []
    batch_size = 1000
    total_rows = 0
    all_sheets = parsed_file.sheets
    all_sheets.each do |sheet|
      parsed_file.default_sheet = sheet
      parsed_file.each_with_index do |row, i|
        if i.zero?
          build_headers(row)
        else
          batch << row
        end
        if batch.size >= batch_size
          process_row(batch)
          batch = []
        end
        total_rows = i
      end
    end
    process_row(batch)
    total_rows
  end

  def self.build_headers(row)
    headers = {}
    row.each_with_index { |x, i| headers[x] = i }
    missing_headers = expected_headers - headers.keys
    raise "Missing required header entry '#{missing_headers[0]}'" unless missing_headers.empty?

    headers
  end

  def self.expected_headers
    %w[ndc bin pcn group state reimbursement_total quantity_dispensed transaction_date health_system_name]
  end

  def self.process_row(batch)
    return unless batch.present?

    Delayed::Job.enqueue MarketFileImportJob.new(batch)
  end
end
