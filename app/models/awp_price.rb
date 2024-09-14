# frozen_string_literal: true

class AwpPrice < ApplicationRecord
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
  batch_size = 10000
  total_rows = 0
  all_sheets = parsed_file.sheets

  all_sheets.each do |sheet|
    parsed_file.default_sheet = sheet

    parsed_file.each_with_index do |row, i|
      if i.zero?
        build_headers(row)
      else
        batch << row
        if batch.size >= batch_size
          process_row(batch)
          batch = []
        end

        total_rows = i
      end
    end

    process_row(batch)
  end

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
    %w[ndc awp_price package_size_quantity awp_per_package]
  end

  def self.process_row(batch)
    return unless batch.present?

    AwpFileImportJob.perform_async(batch)
  end

  def self.import_data(headers, batch)
    # Create a mapping of header names to model attributes
    header_mapping = headers.map(&:downcase).map(&:to_sym)

    batch.each do |data_row|
      # Convert each row into a hash where keys are attribute names
      attributes = header_mapping.zip(data_row).to_h

      # Create or update records based on the attributes hash
      # Assuming `name` or any other attribute can be used to identify the record
      record = new(attributes)
      record.save!
    end
  end
end
