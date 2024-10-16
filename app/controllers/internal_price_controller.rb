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
    search_query = params[:search].to_s.downcase
    health_system_names = InternalPrice.pluck(:health_system_name).uniq.compact

    if search_query.present?
      health_system_names = health_system_names.select { |name| name.downcase.include?(search_query) }
    end

    if search_query.present? && health_system_names.empty?
      render json: { message: "No results found" }, status: :ok
      return
    end

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

  def internal_file_bulk_upload
    health_system_name = params[:health_system_name]

    if InternalPrice.process_file(internal_file_bulk_upload_file, health_system_name)
      render json: { message: 'Internal File successfully uploaded', status: :success }, status: :ok
    else
      render json: { error: 'No file provided', status: :bad_request }, status: :bad_request
    end
  end

  def internal_file_bulk_upload_file
    InternalPrice.open_spreadsheet(params[:internal_price][:file])
  end

  def raw_file_bulk_upload
    health_system_name = params[:health_system_name]
    if RawFile.process_file(raw_file_bulk_upload_file, health_system_name)
      render json: { message: 'Raw File successfully uploaded', status: :success }, status: :ok
    else
      render json: { error: 'No file provided', status: :bad_request }, status: :bad_request
    end
  end

  def raw_file_bulk_upload_file
    RawFile.open_spreadsheet(params[:raw_file][:file])
  end

  def marketing_price_bulk_upload
    health_system_name = params[:health_system_name]
    if MarketingPrice.process_file(marketing_price_bulk_upload_file, health_system_name)
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
    health_system_name = params[:health_system_name]
    if StandardReferencePrice.process_file(standard_reference_price_bulk_upload_file, health_system_name)
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
      MatchNdcCodeJob.perform_async(params[:health_system_name])
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
        claim_count: claim_count(params[:hospital_name]&.gsub('_', ' '), details, params[:sort]),
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
        contract_pharmacy_group: details, claim_count: claim_count(params[:hospital_name]&.gsub('_', ' '), details, params[:sort]),
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
        contract_pharmacy_group: details, claim_count: claim_count(params[:hospital_name]&.gsub('_', ' '), details, params[:sort]),
        total_program_revenue: "$#{total_program_revenue_pharmacy_group(details, params[:sort])}",
        awp: "$#{contract_pharmacy_awp(params[:hospital_name]&.gsub('_', ' '), details, params[:sort]).to_f.round(0)}",
        under_paid_claim: "$#{under_paid_claim(details, params[:sort])}"
      }
    end

    render json: contract_pharmacy_details
  end

  def reimbursement_each_contract_pharmacy_one
    @contract_pharmacy_records = RawFile.search(
      params[:search], nil, nil, nil, nil, params[:hospital_name]&.gsub('_', ' '), nil, nil, nil
    ).where(rx_file_provider_name: params[:contract_pharmacy_name].gsub('_', ' '))
     .all.map(&:contract_pharmacy_name).uniq

    paginated_pharmacy_records = Kaminari.paginate_array(@contract_pharmacy_records)
                                         .page(params[:drug_page])
                                         .per(10)

    if search_params_present? && paginated_pharmacy_records.empty?
      render json: { message: 'No results found' }, status: :not_found
      return
    end

    contract_pharmacy_details = paginated_pharmacy_records.map do |details|
      {
        contract_pharmacy_name: details,
        claim_count: contract_pharmacy_name_level_claim(params[:contract_pharmacy_name].gsub('_', ' '), details, params[:sort]),
        correctly_paid_claim: '$' + contract_pharmacy_name_level_correct_paid_claim(details, params[:sort]).to_s,
        awp:  '$' + contract_pharmacy_name_level_awp(details, params[:sort]).to_s,
        under_paid_claim:  '$' + contract_pharmacy_name_level_under_paid(details, params[:sort]).to_s
      }
    end

    render json: {
      contract_pharmacy_name_details: contract_pharmacy_details,
      total_count: paginated_pharmacy_records.total_count
    }
  end


  def reimbursement_each_contract_pharmacy
    @contract_pharmacy_records = RawFile.search(
      params[:search], nil, nil, nil, nil, params[:hospital_name]&.gsub('_', ' '), nil, nil, nil
    ).where(rx_file_provider_name: params[:contract_pharmacy_name].gsub('_', ' '))
     .where(contract_pharmacy_name: params[:pharmacy_name])
     .map(&:ndc).uniq

    paginated_pharmacy_records = Kaminari.paginate_array(@contract_pharmacy_records)
                                         .page(params[:drug_page])
                                         .per(20)

    if search_params_present? && paginated_pharmacy_records.empty?
      render json: { message: 'No results found' }, status: :not_found
      return
    end

    contract_pharmacy_details = paginated_pharmacy_records.map do |details|
      {
        drug_name: reimbursement_ndc_level_group_drug_name(details).to_s.squish,
        ndc: details,
        total_claims: reimbursement_ndc_level_group_claims(details),
        awp: reimbursement_ndc_level_group_awp(details),
        under_paid_amount: reimbursement_ndc_level_group_under_paid(details)
      }
    end

    render json: {
      contract_pharmacy_details: contract_pharmacy_details,
      total_count: paginated_pharmacy_records.total_count
    }
  end

  def claim_management
    @contract_pharmacy = search_contract_pharmacy
    total_count = total_contract_pharmacy_count
    if params[:matched_status].present? && params[:matched_status] == "matched"
      @contract_pharmacy = search_contract_pharmacy.where(matched_status: true)
      total_count = @contract_pharmacy.count
    elsif params[:matched_status].present?  && params[:matched_status] == "unmatched"
      @contract_pharmacy = search_contract_pharmacy.where(paid_status: nil)
      total_count = @contract_pharmacy.count
    end
    contract_pharmacy_details = map_contract_pharmacy_details(@contract_pharmacy, total_count)

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
    render json: { message: 'Claim status updated successfully' }, status: :ok
  end

  def report_and_analytics
    hospital_name = params[:hospital_name]&.gsub('_', ' ')
    @contract_pharmacy_group_level = RawFile.where(health_system_name: hospital_name).distinct.count(:rx_file_provider_name)
    @contract_pharmacy_name_level = RawFile.where(health_system_name: hospital_name).distinct.count(:contract_pharmacy_name)
    @correctly_paid = RawFile.where(health_system_name: hospital_name, paid_status: "correctly_paid").count
    @under_paid = RawFile.where(health_system_name: hospital_name, paid_status: "under_paid").count
    @over_paid = RawFile.where(health_system_name: hospital_name, paid_status: "over_paid").count
    @contract_pharmacy_names = RawFile.where(health_system_name: hospital_name)
                                       .group(:rx_file_provider_name)
                                       .count
    @hospital_series = {}
    RawFile.where(health_system_name: hospital_name).group(:rx_file_provider_name, :paid_status).count.each do |(provider_name, paid_status), count|
      @hospital_series[provider_name] ||= { correctly_paid: 0, under_paid: 0, over_paid: 0 }
      case paid_status
      when "correctly_paid"
        @hospital_series[provider_name][:correctly_paid] += count
      when "under_paid"
        @hospital_series[provider_name][:under_paid] += count
      when "over_paid"
        @hospital_series[provider_name][:over_paid] += count
      end
    end
    raw_data = RawFile.where(health_system_name: hospital_name)
                      .group(:rx_file_provider_name, :claim_status)
                      .count
    @hospital_series_claims = {}

    raw_data.each do |(provider_name, claim_status), count|
      @hospital_series_claims[provider_name] ||= {}

      if claim_status.present?
        @hospital_series_claims[provider_name][claim_status.to_sym] = count
      else
        @hospital_series_claims[provider_name][:unknown_claim_status] = 0
      end
    end

    @hospital_series_claims.each do |provider_name, claims|
      claims[:unknown_claim_status] ||= 0
    end

    render json: {
      contract_pharmacy_group_level: @contract_pharmacy_group_level,
      contract_pharmacy_name_level: @contract_pharmacy_name_level,
      correctly_paid: @correctly_paid,
      under_paid: @under_paid,
      over_paid: @over_paid,
      contract_pharmacy_names: @contract_pharmacy_names,
      hospital_series: @hospital_series,
      hospital_series_claims: @hospital_series_claims
    }
  end

  private

  def search_contract_pharmacy
    RawFile.search(params[:search], params[:drug_name], params[:ndc],
                   params[:contract_pharmacy_name], params[:contract_pharmacy_group],
                   params[:hospital_name]&.gsub('_', ' '), params[:dispensed_date_start], params[:dispensed_date_end], params[:sort])
           .page(params[:drug_page]).per(20)
  end

  def total_contract_pharmacy_count
    RawFile.search(params[:search], params[:drug_name], params[:ndc],
                   params[:contract_pharmacy_name], params[:contract_pharmacy_group],
                   params[:hospital_name]&.gsub('_', ' '), params[:dispensed_date_start], params[:dispensed_date_end], params[:sort]).count
  end

  def map_contract_pharmacy_details(contract_pharmacies, total_count)
    {
      count: total_count,
      details: contract_pharmacies.map do |pharmacy_record|
        {
          id: pharmacy_record.id, contract_pharmacy_name: pharmacy_record.contract_pharmacy_name,
          contract_pharmacy_group: pharmacy_record.rx_file_provider_name, drug_name: pharmacy_record.drug_name.squish,
          ndc_code: pharmacy_record.ndc, awp: awp_price(pharmacy_record),
          program_revenue: "$#{pharmacy_record.program_revenue.round(0)}",
          expected_reimbursement: if !pharmacy_record.paid_status.present? && !expected_reimbursement_matching(pharmacy_record).present?
                                    ''
                                  elsif pharmacy_record.paid_status.present? && expected_reimbursement_matching(pharmacy_record).present?
                                    "$#{expected_reimbursement_matching(pharmacy_record).round(0)}"
                                  else
                                    ''
                                  end,
          reimbursement_spread: reimbursement_spread(pharmacy_record).present? ? "$#{reimbursement_spread(pharmacy_record).round(0)}" : '',
          paid_status: pharmacy_record.paid_status.try(:gsub, "_", " ")&.capitalize,
          dispensed_date: pharmacy_record.dispensed_date, claim_status: pharmacy_record.claim_status,
        }
      end
    }
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
