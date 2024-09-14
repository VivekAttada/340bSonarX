# frozen_string_literal: true

class InternalPriceController < ApplicationController
  include ApplicationHelper

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

  def all_contract_pharmacies
    @contract_pharmacy = RawFile.where(health_system_name: params[:hospital_name]).all.map(&:rx_file_provider_name).uniq
  end

  def dashboard
    @contract_pharmacy = RawFile.where(health_system_name: params[:hospital_name]).all.map(&:rx_file_provider_name).uniq
  end

  def reimbursement
    @contract_pharmacy = RawFile.where(health_system_name: params[:hospital_name]).all.map(&:rx_file_provider_name).uniq
  end

  def reimbursement_each_contract_pharmacy
    @contract_pharmacy_records = RawFile
                                 .where(health_system_name: params[:hospital_name])
                                 .where(rx_file_provider_name: params[:contract_pharmacy_name])
                                 .where(matched_status: true)
                                 .page(params[:drug_page])
                                 .per(20)
  end

  def claim_management
    @contract_pharmacy = RawFile.where(health_system_name: params[:hospital_name]).all.map(&:rx_file_provider_name).uniq
  end

  def claim_each_contract_pharmacy
    @contract_pharmacy_records = RawFile
                                 .where(health_system_name: params[:hospital_name])
                                 .where(rx_file_provider_name: params[:contract_pharmacy_name])
                                 .where(matched_status: true)
                                 .page(params[:drug_page])
                                 .per(10)
  end

  def update_claim_status
    RawFile.where(ndc: params[:ndc]).update(claim_status: params[:claim])
    MarketingPrice.where(ndc: params[:ndc]).update(claim_status: params[:claim])
    InternalPrice.where(ndc: params[:ndc]).update(claim_status: params[:claim])
    redirect_back(fallback_location: root_path)
  end
end
