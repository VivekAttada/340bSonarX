# frozen_string_literal: true

class InternalPriceController < ApplicationController
  include ApplicationHelper
  skip_before_action :verify_authenticity_token,
                     only: %i[awp_file_bulk_upload internal_file_bulk_upload raw_file_bulk_upload marketing_price_bulk_upload
                              update_claim_status standard_reference_price_file_bulk_upload match_ndc_code add_health_system]

  # def index
  #  @internal_price = InternalPrice.new
  #  @marketing_price = MarketingPrice.new
  #  @raw_file = RawFile.new
  #  @awp_price = AwpPrice.new
  #  @standard_reference_file = StandardReferencePrice.new
  #  @internal_details = InternalPrice.all.map(&:health_system_name).uniq.compact
  # end

  def add_health_system
    if params[:hospital_name].present?
      InternalPrice.create(health_system_name: params[:hospital_name])
      render json: { message: 'Health System added successfully', status: :success }, status: :ok
    else
      render json: { error: 'Please insert Health System Name', status: :bad_request }, status: :bad_request
    end
  end

  def all_health_systems
    health_system_names = InternalPrice.pluck(:health_system_name).uniq.compact

    data = health_system_names.map do |name|
      {
        health_system_name: name,
        total_health_system_claims: total_health_system_claims(name),
        total_revenue: "$#{total_revenue(name).round(0)}",
        total_reimbursement: "$#{total_reimbursement(name).round(0)}"
      }
    end
    render json: data, status: :ok
  end

  # def internal_file_bulk_upload
  #  InternalPrice.process_file(internal_file_bulk_upload_file)
  #  flash[:success] = 'Internal File successfully uploaded'
  #  redirect_back(fallback_location: root_path)
  # end

  def internal_file_bulk_upload
    if InternalPrice.process_file(internal_file_bulk_upload_file)
      render json: { message: 'Internal File successfully uploaded', status: :success }, status: :ok
    else
      render json: { error: 'No file provided', status: :bad_request }, status: :bad_request
    end
  end

  def internal_file_bulk_upload_file
    InternalPrice.open_spreadsheet(params[:internal_price][:file])
  end

  # def raw_file_bulk_upload
  #  RawFile.process_file(raw_file_bulk_upload_file)
  #  flash[:success] = 'Raw File successfully uploaded'
  #  redirect_back(fallback_location: root_path)
  # end

  def raw_file_bulk_upload
    if RawFile.process_file(raw_file_bulk_upload_file)
      render json: { message: 'Raw File successfully uploaded', status: :success }, status: :ok
    else
      render json: { error: 'No file provided', status: :bad_request }, status: :bad_request
    end
  end

  def raw_file_bulk_upload_file
    RawFile.open_spreadsheet(params[:raw_file][:file])
  end

  # def marketing_price_bulk_upload
  #  MarketingPrice.process_file(marketing_price_bulk_upload_file)
  #  flash[:success] = 'Market Price File successfully uploaded'
  #  redirect_back(fallback_location: root_path)
  # end

  def marketing_price_bulk_upload
    if MarketingPrice.process_file(marketing_price_bulk_upload_file)
      render json: { message: 'Market Price File successfully uploaded', status: :success }, status: :ok
    else
      render json: { error: 'No file provided', status: :bad_request }, status: :bad_request
    end
  end

  def marketing_price_bulk_upload_file
    MarketingPrice.open_spreadsheet(params[:marketing_price][:file])
  end

  def awp_file_bulk_upload
    if params[:awp_price].present? && params[:awp_price][:file].present?
      AwpPrice.process_file(awp_file_bulk_upload_file)
      render json: { message: 'AWP Price File successfully uploaded', status: :success }, status: :ok
    else
      render json: { error: 'No file provided', status: :bad_request }, status: :bad_request
    end
  end

  def awp_file_bulk_upload_file
    AwpPrice.open_spreadsheet(params[:awp_price][:file])
  end

  def standard_reference_price_file_bulk_upload
    if StandardReferencePrice.process_file(standard_reference_price_bulk_upload_file)
      render json: { message: 'Standard Reference File successfully uploaded', status: :success }, status: :ok
    else
      render json: { error: 'No file provided', status: :bad_request }, status: :bad_request
    end
  end

  def standard_reference_price_bulk_upload_file
    StandardReferencePrice.open_spreadsheet(params[:standard_reference_price][:file])
  end

  def match_ndc_code
    match_param = params[:match]
    if match_param.present?
      MatchNdcCodeJob.perform_async
      render json: { message: 'MatchNdcCodeJob has been triggered.' }, status: :ok
    else
      render json: { error: 'Missing match parameter.' }, status: :unprocessable_entity
    end
  end

  def all_contract_pharmacies
    @contract_pharmacy = RawFile.search(
      params[:search], params[:drug_name],
      params[:ndc], params[:contract_pharmacy_name],
      params[:contract_pharmacy_group], params[:hospital_name]&.gsub('_', ' '),
      params[:dispensed_date_start], params[:dispensed_date_end], params[:sort])
                                .all.map(&:rx_file_provider_name).uniq

    contract_pharmacy_details = @contract_pharmacy.map do |details|
      {
        contract_pharmacy_group: details,
        claim_count: claim_count(details, params[:sort]),
        revenue: "$#{contract_pharmacies_revenue(details, params[:sort]).round(0)}",
        reimbursement: "$#{contract_pharmacy_reimbursement(details, params[:sort]).to_f.round(0)}"
      }
    end

    render json: contract_pharmacy_details
  end

  def dashboard
    @contract_pharmacy = RawFile.search(params[:search], params[:drug_name],
                                        params[:ndc], params[:contract_pharmacy_name], params[:contract_pharmacy_group],
                                        params[:hospital_name]&.gsub('_', ' '), params[:dispensed_date_start], params[:dispensed_date_end], params[:sort])
                                .all.map(&:rx_file_provider_name).uniq

    contract_pharmacy_details = @contract_pharmacy.map do |details|
      {
        contract_pharmacy_group: details, claim_count: claim_count(details, params[:sort]),
        correctly_paid_claim: "$#{correctly_paid_claim(details, params[:sort])}",
        under_paid_claim: "$#{under_paid_claim(details, params[:sort])}",
        over_paid_claim: "$#{over_paid_claim(details, params[:sort])}"
      }
    end

    render json: contract_pharmacy_details
  end

  def reimbursement
    @contract_pharmacy = RawFile.search(params[:search], params[:drug_name],
                                        params[:ndc], params[:contract_pharmacy_name],
                                        params[:contract_pharmacy_group], params[:hospital_name]&.gsub('_', ' '),
                                        params[:dispensed_date_start], params[:dispensed_date_end], params[:sort])
                                .all.map(&:rx_file_provider_name).uniq
    if @contract_pharmacy.empty?
      render json: { message: 'No results found' }, status: :not_found
      return
    end

    contract_pharmacy_details = @contract_pharmacy.map do |details|
      {
        contract_pharmacy_group: details, claim_count: claim_count(details, params[:sort]),
        correctly_paid_claim: "$#{correctly_paid_claim(details, params[:sort])}",
        awp: "$#{contract_pharmacy_awp(details, params[:sort]).to_f.round(0)}",
        under_paid_claim: "$#{under_paid_claim(details, params[:sort])}"
      }
    end

    render json: contract_pharmacy_details
  end

  def reimbursement_each_contract_pharmacy
    @contract_pharmacy_records = RawFile.search(
      params[:search], nil, nil, nil, nil, nil, nil, nil, nil )
                                        .where(rx_file_provider_name: params[:contract_pharmacy_name].gsub('_', ' '))
                                        .page(params[:drug_page]).per(20)
    if search_params_present? && @contract_pharmacy_records.empty?
      render json: { message: 'No results found' }, status: :not_found
      return
    end
    contract_pharmacy_details = @contract_pharmacy_records.map do |details|
      {
        contract_pharmacy_name: details.contract_pharmacy_name,
        ndc: details.ndc,
        uniq_contract_pharmacy: uniq_contract_pharmacy(details.ndc, params[:sort]),
        paid_status: details.paid_status
      }
    end
    render json: contract_pharmacy_details
  end

  def claim_management
    @contract_pharmacy = search_contract_pharmacy
    contract_pharmacy_details = map_contract_pharmacy_details(@contract_pharmacy)

    if search_params_present? && contract_pharmacy_details.empty?
      render json: { message: 'No results found' }, status: :not_found
    else
      render json: contract_pharmacy_details
    end
  end

  def claim_each_contract_pharmacy
    contract_pharmacy_record = RawFile.find_by_id(params[:id])

    if contract_pharmacy_record
      render json: build_contract_pharmacy_details(contract_pharmacy_record)
    else
      render json: { message: 'Contract pharmacy not found' }, status: :not_found
    end
  end

  def update_claim_status
    RawFile.find_by_id(params[:id]).update(claim_status: params[:claim])
    # MarketingPrice.where(ndc: params[:ndc]).update(claim_status: params[:claim])
    # InternalPrice.where(ndc: params[:ndc]).update(claim_status: params[:claim])
    render json: { message: 'Claim status updated successfully' }, status: :ok
  end

  def internal_price_sample_file
    file_path = Rails.root.join('public', 'docs', 'internal_price_sample_file.xlsx')
    if File.exist?(file_path)
      send_file file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                           disposition: 'attachment'
    else
      render json: { error: 'File not found' }, status: :not_found
    end
  end

  def marketing_price_sample_file
    file_path = Rails.root.join('public', 'docs', 'marketing_price_sample_file.xlsx')
    if File.exist?(file_path)
      send_file file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                           disposition: 'attachment'
    else
      render json: { error: 'File not found' }, status: :not_found
    end
  end

  def raw_file_sample_file
    file_path = Rails.root.join('public', 'docs', 'raw_file_sample_file.xlsx')
    if File.exist?(file_path)
      send_file file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                           disposition: 'attachment'
    else
      render json: { error: 'File not found' }, status: :not_found
    end
  end

  def awp_sample_file
    file_path = Rails.root.join('public', 'docs', 'awp_sample_file.xlsx')
    if File.exist?(file_path)
      send_file file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                           disposition: 'attachment'
    else
      render json: { error: 'File not found' }, status: :not_found
    end
  end

  def standard_reference_price_sample_file
    file_path = Rails.root.join('public', 'docs', 'standard_reference_price_sample_file.xlsx')
    if File.exist?(file_path)
      send_file file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                           disposition: 'attachment'
    else
      render json: { error: 'File not found' }, status: :not_found
    end
  end

  private

  def search_contract_pharmacy
    RawFile.search(params[:search], params[:drug_name], params[:ndc],
                   params[:contract_pharmacy_name], params[:contract_pharmacy_group],
                   params[:hospital_name]&.gsub('_', ' '), params[:dispensed_date_start], params[:dispensed_date_end], params[:sort])
           .page(params[:drug_page]).per(20)
  end

  def map_contract_pharmacy_details(contract_pharmacies)
    contract_pharmacies.map do |pharmacy_record|
      {
        id: pharmacy_record.id, contract_pharmacy_name: pharmacy_record.contract_pharmacy_name,
        contract_pharmacy_group: pharmacy_record.rx_file_provider_name, drug_name: pharmacy_record.drug_name.squish,
        ndc_code: pharmacy_record.ndc, awp: awp_price(pharmacy_record),
        program_revenue: "$#{pharmacy_record.program_revenue.round(0)}",
        expected_reimbursement: pharmacy_record.paid_status.present? ? "$#{expected_reimbursement_matching(pharmacy_record).round(0)}" : '',
        reimbursement_spread: reimbursement_spread(pharmacy_record).present? ? "$#{reimbursement_spread(pharmacy_record).round(0)}" : '',
        paid_status: pharmacy_record.paid_status,
        dispensed_date: pharmacy_record.dispensed_date, claim_status: pharmacy_record.claim_status,
      }
    end
  end

  def search_params_present?
    params[:search].present? || params[:drug_name].present? || params[:ndc].present? ||
      params[:contract_pharmacy_name].present? || params[:contract_pharmacy_group].present? ||
      params[:hospital_name].present?
  end

  def build_contract_pharmacy_details(record)
    {
      processed_date: record.processed_date,
      pharmacy_npi: record.pharmacy_npi,
      rx: record.rx,
      manufacturer: record.manufacturer.squish,
      drug_class: record.drug_class,
      packages_dispensed: record.packages_dispensed,
      mdq: record.mdq,
      rx_written_date: record.rx_written_date,
      fill: record.fill,
      dispensed_quantity: record.dispensed_quantity,
      days_supply: record.days_supply,
      patient_paid: record.patient_paid,
      admin_fee: "$#{record.admin_fee}",
      dispensing_fee: "$#{record.dispensing_fee}",
      primary_group: record.primary_group,
      primary_bin: record.primary_bin,
      primary_pcn: record.primary_pcn,
      primary_payer_name: record.primary_payer_name,
      primary_plan_name: record.primary_plan_name,
      primary_plan_type: record.primary_plan_type,
      primary_benefit_plan_name: record.primary_benefit_plan_name
    }
  end
end
