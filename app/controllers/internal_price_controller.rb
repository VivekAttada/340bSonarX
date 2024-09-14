# frozen_string_literal: true

class InternalPriceController < ApplicationController
  include ApplicationHelper
  skip_before_action :verify_authenticity_token, only: [:awp_file_bulk_upload, :internal_file_bulk_upload, :raw_file_bulk_upload, :marketing_price_bulk_upload, :update_claim_status]

  def index
    @internal_price = InternalPrice.new
    @marketing_price = MarketingPrice.new
    @raw_file = RawFile.new
    @awp_price = AwpPrice.new
    @standard_reference_file = StandardReferencePrice.new
    @internal_details = InternalPrice.all.map(&:health_system_name).uniq.compact
  end

  def internal_file_bulk_upload
    InternalPrice.process_file(internal_file_bulk_upload_file)
    flash[:success] = 'Internal File successfully uploaded'
    redirect_back(fallback_location: root_path)
  end

  def internal_file_bulk_upload_file
    InternalPrice.open_spreadsheet(params[:internal_price][:file])
  end

  def raw_file_bulk_upload
    RawFile.process_file(raw_file_bulk_upload_file)
    flash[:success] = 'Raw File successfully uploaded'
    redirect_back(fallback_location: root_path)
  end

  def raw_file_bulk_upload_file
    RawFile.open_spreadsheet(params[:raw_file][:file])
  end

  def marketing_price_bulk_upload
    MarketingPrice.process_file(marketing_price_bulk_upload_file)
    flash[:success] = 'Market Price File successfully uploaded'
    redirect_back(fallback_location: root_path)
  end

  def marketing_price_bulk_upload_file
    MarketingPrice.open_spreadsheet(params[:marketing_price][:file])
  end

  def awp_file_bulk_upload
    AwpPrice.process_file(awp_file_bulk_upload_file)
    flash[:success] = 'AWP Price File successfully uploaded'
    redirect_back(fallback_location: root_path)
  end

  def awp_file_bulk_upload_file
    AwpPrice.open_spreadsheet(params[:awp_price][:file])
  end

  def standard_reference_price_file_bulk_upload
    StandardReferencePrice.process_file(standard_reference_price_bulk_upload_file)
    flash[:success] = 'Standard Reference Price File successfully uploaded'
    redirect_back(fallback_location: root_path)
  end

  def standard_reference_price_bulk_upload_file
    StandardReferencePrice.open_spreadsheet(params[:standard_reference_price][:file])
  end

  # def all_contract_pharmacies
  #   @contract_pharmacy = RawFile.search(params[:search], params[:hospital_name], params[:sort])
  #                               .all.map(&:rx_file_provider_name).uniq
  # end

  def all_contract_pharmacies
    @contract_pharmacy = RawFile.search(params[:search], params[:hospital_name], params[:sort])
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
  #   @contract_pharmacy = RawFile.search(params[:search], params[:hospital_name], params[:sort]).all.map(&:rx_file_provider_name).uniq
  # end

  def dashboard
    @contract_pharmacy = RawFile.search(params[:search], params[:hospital_name], params[:sort])
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
  #   @contract_pharmacy = RawFile.search(params[:search], params[:hospital_name], params[:sort]).all.map(&:rx_file_provider_name).uniq
  # end

  def reimbursement
    @contract_pharmacy = RawFile.search(params[:search], params[:hospital_name], params[:sort])
                                .all.map(&:rx_file_provider_name).uniq

    if @contract_pharmacy.empty?
      render json: { message: 'No results found' }, status: :not_found
      return
    end

    contract_pharmacy_details = @contract_pharmacy.map do |details|
      {
        provider_name: details,
        claim_count: claim_count(details, params[:sort]),
        correctly_paid_claim: correctly_paid_claim(details, params[:sort]),
        awp: contract_pharmacy_awp(details, params[:sort]).to_f.round(2),
        under_paid_claim: under_paid_claim(details, params[:sort]),
      }
    end

    render json: contract_pharmacy_details
  end


  # def reimbursement_each_contract_pharmacy
  #   @contract_pharmacy_records = RawFile
  #                                .search(params[:search], params[:hospital_name], params[:sort])
  #                                .where(rx_file_provider_name: params[:contract_pharmacy_name])
  #                                .page(params[:drug_page])
  #                                .per(20)
  # end

  def reimbursement_each_contract_pharmacy
     @contract_pharmacy_records = RawFile
                                 .search(params[:search], params[:hospital_name], params[:sort])
                                 .where(rx_file_provider_name: params[:contract_pharmacy_name])
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

  # def claim_management
  #   @contract_pharmacy = RawFile.search(params[:search], params[:hospital_name], params[:sort]).all.map(&:rx_file_provider_name).uniq
  # end

  def claim_management
    @contract_pharmacy = RawFile.search(params[:search], params[:hospital_name], params[:sort])
                                .all.map(&:rx_file_provider_name).uniq

    contract_pharmacy_details = @contract_pharmacy.map do |details|
      {
        provider_name: details,
        claim_count: claim_count(details, params[:sort]),
      }
    end

    render json: contract_pharmacy_details
  end

  # def claim_each_contract_pharmacy
  #   @contract_pharmacy_records = RawFile.search(params[:search], params[:hospital_name], params[:sort])
  #                                .where(rx_file_provider_name: params[:contract_pharmacy_name])
  #                                .page(params[:drug_page])
  #                                .per(10)
  # end

  def claim_each_contract_pharmacy
    @contract_pharmacy_records = RawFile.search(params[:search], params[:hospital_name], params[:sort])
                                 .where(rx_file_provider_name: params[:contract_pharmacy_name])
                                 .page(params[:drug_page])
                                 .per(10)

    contract_pharmacy_details = @contract_pharmacy_records.map do |details|
      {
        provider_name: details.rx_file_provider_name,
        ndc: details.ndc,
        claim_count: uniq_contract_pharmacy_claim(details.ndc, params[:sort])
      }
    end

    render json: contract_pharmacy_details
  end

  # def update_claim_status
  #   RawFile.where(ndc: params[:ndc]).update(claim_status: params[:claim])
  #   MarketingPrice.where(ndc: params[:ndc]).update(claim_status: params[:claim])
  #   InternalPrice.where(ndc: params[:ndc]).update(claim_status: params[:claim])
  #   redirect_back(fallback_location: root_path)
  # end

  def update_claim_status
    RawFile.where(ndc: params[:ndc]).update(claim_status: params[:claim])
    MarketingPrice.where(ndc: params[:ndc]).update(claim_status: params[:claim])
    InternalPrice.where(ndc: params[:ndc]).update(claim_status: params[:claim])

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
