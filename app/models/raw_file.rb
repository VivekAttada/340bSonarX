# frozen_string_literal: true

class RawFile < ApplicationRecord
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
    %w[processed_date three_forty_b_id contract_pharmacy_name pharmacy_npi rx ndc drug_name
       manufacturer drug_class packages_dispensed mdq rx_written_date dispensed_date
       fill dispensed_quantity days_supply program_revenue patient_paid admin_fee
       dispensing_fee transaction_code card_holder primary_bin primary_pcn primary_group primary_payer_name
       primary_plan_name primary_plan_type primary_benefit_plan_name rx_file_provider_name]
  end

  def self.process_row(batch, health_system_name)
    return unless batch.present?

    batch.each do |row|
      row.map! do |value|
        value.is_a?(Date) ? value.to_s : value
      end
    end

    RawFileImportJob.perform_async(batch, health_system_name)
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

  def self.search(search_term, drug_name, ndc, contract_pharmacy_name, contract_pharmacy_group, hospital_name, dispensed_date_start, dispensed_date_end, sort)
    query = where(health_system_name: hospital_name)

    if search_term.present?
      query = query.where('rx_file_provider_name ILIKE :search OR health_system_name ILIKE :search OR
                           drug_name ILIKE :search OR manufacturer ILIKE :search OR ndc ILIKE :search OR drug_class ILIKE :search',
                          search: "%#{search_term.strip}%")
    end

    query = query.where('drug_name ILIKE :search',
                          search: "%#{drug_name.strip}%") if drug_name.present?

    if dispensed_date_start.present? && dispensed_date_end.present?
      dispensed_date_start = Date.parse(dispensed_date_start)
      dispensed_date_end = Date.parse(dispensed_date_end)
      query = query.where(dispensed_date: dispensed_date_start..dispensed_date_end)
    elsif dispensed_date_start.present?
      dispensed_date_start = Date.parse(dispensed_date_start)
      query = query.where(dispensed_date: dispensed_date_start)
    end
    query = query.where(ndc: ndc) if ndc.present?
    query = query.where('contract_pharmacy_name ILIKE :search',
                          search: "%#{contract_pharmacy_name.strip}%") if contract_pharmacy_name.present?
    query = query.where('rx_file_provider_name ILIKE :search',
                          search: "%#{contract_pharmacy_group.strip}%") if contract_pharmacy_group.present?

    if sort.present?
      case sort
      when "four_matched"
        query = query.where(matched_ndc_bin_pcn_state: true)
      when "three_matched"
        query = query.where(matched_ndc_bin_pcn: true)
      when "two_matched"
        query = query.where(matched_ndc_bin: true)
      end
    else
     query
    end
  end
end