# frozen_string_literal: true

class InternalPriceController < ApplicationController
 include ApplicationHelper
 skip_before_action :verify_authenticity_token, only: [:awp_file_bulk_upload, :internal_file_bulk_upload, :raw_file_bulk_upload, :marketing_price_bulk_upload, :update_claim_status, :standard_reference_price_file_bulk_upload, :match_ndc_code]

 # def index
 #  @internal_price = InternalPrice.new
 #  @marketing_price = MarketingPrice.new
 #  @raw_file = RawFile.new
 #  @awp_price = AwpPrice.new
 #  @standard_reference_file = StandardReferencePrice.new
 #  @internal_details = InternalPrice.all.map(&:health_system_name).uniq.compact
 # end

 def all_health_systems
  health_system_names = InternalPrice.pluck(:health_system_name).uniq.compact

  data = health_system_names.map do |name|
   {
    health_system_name: name,
    total_health_system_claims: total_health_system_claims(name),
    total_revenue: '$' + total_revenue(name).round(0).to_s,
    total_reimbursement: '$' + total_reimbursement(name).round(0).to_s
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

 # def awp_file_bulk_upload
 #  AwpPrice.process_file(awp_file_bulk_upload_file)
 #  flash[:success] = 'AWP Price File successfully uploaded'
 #  redirect_back(fallback_location: root_path)
 # end

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

 # def standard_reference_price_file_bulk_upload
 #  StandardReferencePrice.process_file(standard_reference_price_bulk_upload_file)
 #  flash[:success] = 'Standard Reference Price File successfully uploaded'
 #  redirect_back(fallback_location: root_path)
 # end

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

 # def all_contract_pharmacies
 #  @contract_pharmacy = RawFile.search(params[:search], params[:hospital_name], params[:sort])
 #                .all.map(&:rx_file_provider_name).uniq
 # end

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
  @contract_pharmacy = RawFile.search(params[:search], params[:hospital_name].gsub("_"," "), params[:sort])
                .all.map(&:rx_file_provider_name).uniq

  contract_pharmacy_details = @contract_pharmacy.map do |details|
   {
    provider_name: details,
    claim_count: claim_count(details, params[:sort]),
    revenue: '$' + contract_pharmacies_revenue(details, params[:sort]).round(0).to_s,
    reimbursement: '$' + contract_pharmacy_reimbursement(details, params[:sort]).to_f.round(0).to_s
   }
  end

  render json: contract_pharmacy_details
 end

 # def dashboard
 #  @contract_pharmacy = RawFile.search(params[:search], params[:hospital_name], params[:sort]).all.map(&:rx_file_provider_name).uniq
 # end

 def dashboard
  @contract_pharmacy = RawFile.search(params[:search], params[:hospital_name].gsub("_"," "), params[:sort])
                .all.map(&:rx_file_provider_name).uniq

  contract_pharmacy_details = @contract_pharmacy.map do |details|
   {
    provider_name: details,
    claim_count: claim_count(details, params[:sort]),
    correctly_paid_claim: '$' + correctly_paid_claim(details, params[:sort]).to_s,
    under_paid_claim: '$' + under_paid_claim(details, params[:sort]).to_s,
    over_paid_claim: '$' + over_paid_claim(details, params[:sort]).to_s
   }
  end

  render json: contract_pharmacy_details
 end

 # def reimbursement
 #  @contract_pharmacy = RawFile.search(params[:search], params[:hospital_name], params[:sort]).all.map(&:rx_file_provider_name).uniq
 # end

 def reimbursement
  @contract_pharmacy = RawFile.search(params[:search], params[:hospital_name].gsub("_"," "), params[:sort])
                .all.map(&:rx_file_provider_name).uniq

  if @contract_pharmacy.empty?
   render json: { message: 'No results found' }, status: :not_found
   return
  end

  contract_pharmacy_details = @contract_pharmacy.map do |details|
   {
    provider_name: details,
    claim_count: claim_count(details, params[:sort]),
    correctly_paid_claim: '$' + correctly_paid_claim(details, params[:sort]).to_s,
    awp: '$' + contract_pharmacy_awp(details, params[:sort]).to_f.round(0).to_s,
    under_paid_claim: '$' + under_paid_claim(details, params[:sort]).to_s,
   }
  end

  render json: contract_pharmacy_details
 end


 # def reimbursement_each_contract_pharmacy
 #  @contract_pharmacy_records = RawFile
 #                .search(params[:search], params[:hospital_name], params[:sort])
 #                .where(rx_file_provider_name: params[:contract_pharmacy_name])
 #                .page(params[:drug_page])
 #                .per(20)
 # end

 def reimbursement_each_contract_pharmacy
  @contract_pharmacy_records = RawFile
                .search(params[:search], params[:hospital_name].gsub("_"," "), params[:sort])
                .where(rx_file_provider_name: params[:contract_pharmacy_name].gsub("_"," "))
                .page(params[:drug_page])
                .per(20)

  if @contract_pharmacy_records.empty?
   render json: { message: 'No results found' }, status: :not_found
   return
  end

  contract_pharmacy_details = @contract_pharmacy_records.map do |details|
   {
    provider_name: details.rx_file_provider_name,
    ndc: details.ndc,
    uniq_contract_pharmacy: uniq_contract_pharmacy(details.ndc, params[:sort]),
    paid_status: details.paid_status
   }
  end

  render json: contract_pharmacy_details
 end

  def claim_management
    @contract_pharmacy = RawFile.search(params[:search], params[:hospital_name].gsub("_", " "), params[:sort]).page(params[:drug_page]).per(20)

    contract_pharmacy_details = @contract_pharmacy.map do |pharmacy_record|
      {
        id: pharmacy_record.id,
        contract_pharmacy_name: pharmacy_record.rx_file_provider_name,
        drug_name: pharmacy_record.drug_name.squish,
        ndc_code: pharmacy_record.ndc,
        awp: awp_price(pharmacy_record),
        program_revenue: '$' + pharmacy_record.program_revenue.to_s,
        expected_reimbursement: '',
        reimbursement_spread: '',
        paid_status: pharmacy_record.paid_status,
        dispensed_date: pharmacy_record.dispensed_date,
      }
    end

    if params[:search].present? && contract_pharmacy_details.empty?
      render json: { message: "No results found for #{params[:search]}" }, status: :not_found
    else
      render json: contract_pharmacy_details
    end
  end

  def claim_each_contract_pharmacy
    # @contract_pharmacy_records = RawFile.search(params[:search], params[:hospital_name].gsub("_"," "), params[:sort])
    #               .where(rx_file_provider_name: params[:contract_pharmacy_name].gsub("_"," "))
    #               .page(params[:drug_page])
    #               .per(10)

    contract_pharmacy_record = RawFile.find_by_id(params[:id])

    contract_pharmacy_details =
     {
      processed_date: contract_pharmacy_record.processed_date,
      pharmacy_npi: contract_pharmacy_record.pharmacy_npi,
      rx: contract_pharmacy_record.rx,
      manufacturer: contract_pharmacy_record.manufacturer.squish,
      drug_class: contract_pharmacy_record.drug_class,
      packages_dispensed: contract_pharmacy_record.packages_dispensed,
      mdq: contract_pharmacy_record.mdq,
      rx_written_date: contract_pharmacy_record.rx_written_date,
      fill: contract_pharmacy_record.fill,
      dispensed_quantity: contract_pharmacy_record.dispensed_quantity,
      days_supply: contract_pharmacy_record.days_supply,
      patient_paid: contract_pharmacy_record.patient_paid,
      admin_fee: '$' + contract_pharmacy_record.admin_fee.to_s,
      dispensing_fee: '$' + contract_pharmacy_record.dispensing_fee.to_s,
      primary_group: contract_pharmacy_record.primary_group,
      primary_bin: contract_pharmacy_record.primary_bin,
      primary_pcn: contract_pharmacy_record.primary_pcn,
      primary_payer_name: contract_pharmacy_record.primary_payer_name,
      primary_plan_name: contract_pharmacy_record.primary_plan_name,
      primary_plan_type: contract_pharmacy_record.primary_plan_type,
      primary_benefit_plan_name: contract_pharmacy_record.primary_benefit_plan_name,
     }

    render json: contract_pharmacy_details
  end

   # def update_claim_status
   #  RawFile.where(ndc: params[:ndc]).update(claim_status: params[:claim])
   #  MarketingPrice.where(ndc: params[:ndc]).update(claim_status: params[:claim])
   #  InternalPrice.where(ndc: params[:ndc]).update(claim_status: params[:claim])
   #  redirect_back(fallback_location: root_path)
   # end

  def update_claim_status
    RawFile.find_by_id(params[:id]).update(claim_status: params[:claim])
    # MarketingPrice.where(ndc: params[:ndc]).update(claim_status: params[:claim])
    # InternalPrice.where(ndc: params[:ndc]).update(claim_status: params[:claim])
    render json: { message: 'Claim status updated successfully' }, status: :ok
  end

   def internal_price_sample_file
    file_path = Rails.root.join('public', 'docs', 'internal_price_sample_file.xlsx')
    if File.exist?(file_path)
     send_file file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', disposition: 'attachment'
    else
     render json: { error: 'File not found' }, status: :not_found
    end
   end

 def marketing_price_sample_file
  file_path = Rails.root.join('public', 'docs', 'marketing_price_sample_file.xlsx')
  if File.exist?(file_path)
   send_file file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', disposition: 'attachment'
  else
   render json: { error: 'File not found' }, status: :not_found
  end
 end

 def raw_file_sample_file
  file_path = Rails.root.join('public', 'docs', 'raw_file_sample_file.xlsx')
  if File.exist?(file_path)
   send_file file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', disposition: 'attachment'
  else
   render json: { error: 'File not found' }, status: :not_found
  end
 end

 def awp_sample_file
  file_path = Rails.root.join('public', 'docs', 'awp_sample_file.xlsx')
  if File.exist?(file_path)
   send_file file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', disposition: 'attachment'
  else
   render json: { error: 'File not found' }, status: :not_found
  end
 end

 def standard_reference_price_sample_file
  file_path = Rails.root.join('public', 'docs', 'standard_reference_price_sample_file.xlsx')
  if File.exist?(file_path)
   send_file file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', disposition: 'attachment'
  else
   render json: { error: 'File not found' }, status: :not_found
  end
 end
end
