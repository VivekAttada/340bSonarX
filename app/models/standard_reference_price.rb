
# frozen_string_literal: true

class StandardReferencePrice < ApplicationRecord
  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when '.csv' then Roo::CSV.new(file.path)
    when '.xls' then Roo::Excel.new(file.path)
    when '.xlsx' then Roo::Excelx.new(file.path)
    else
      raise "Unknown file type: #{file.original_filename}"
    end
  end

    def self.process_file(parsed_file, health_system_name)
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
	          process_row(batch, health_system_name)
	          batch = []
	        end

	        total_rows = i
	      end
	    end

	    process_row(batch, health_system_name)
	  end

	  total_rows
    end

	def self.build_headers(row)
	  headers = {}
	  row.each_with_index { |x, i| headers[x] = i }
	  missing_headers = expected_headers - headers.keys.map(&:downcase).map { |key| key.gsub(" ", "_") }
	  raise "Missing required header entry '#{missing_headers[0]}'" unless missing_headers.empty?

	  headers
	end

	def self.expected_headers
	  %w[ndc awp package_size awp_per_package_size reimbursement_per_quantity_dispensed]
	end

	def self.process_row(batch, health_system_name)
	  return unless batch.present?

	  StandardReferencePriceImportJob.perform_async(batch, health_system_name)
	end


	def self.import_data(headers, batch, health_system_name)
    header_mapping = headers.map(&:downcase).map(&:to_sym)
    batch.each do |data_row|

      attributes = header_mapping.zip(data_row).to_h

      attributes[:health_system_name] = health_system_name

      record = new(attributes)
      record.save!
    end
  end
end
