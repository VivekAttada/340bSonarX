# frozen_string_literal: true

module ApplicationHelper
  def total_health_system_claims(details)
    RawFile.where(health_system_name: details).where(matched_status: true).where.not(paid_status: nil).count
  end

  def total_revenue(details)
    RawFile.where(health_system_name: details).where(matched_status: true).sum(:program_revenue)
  end

  def total_reimbursement(details)
    ndc = RawFile.where(health_system_name: details, matched_status: true).all.map(&:ndc)
    AwpPrice.where(ndc: ndc).map { |price| price.awp.to_f }.sum
  end

  def contract_pharmacy_reimbursement(details, sort)
    query = RawFile.where(health_system_name: params[:hospital_name].gsub('_', ' '),
                          rx_file_provider_name: details).where.not(paid_status: nil)

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
      query = query.where(matched_status: true)
    end

    ndc = query.all.map(&:ndc)
    AwpPrice.where(ndc: ndc).map { |price| price.awp.to_f }.sum
  end

  def contract_pharmacies_revenue(details, sort)
    query = RawFile.where(health_system_name: params[:hospital_name].gsub('_', ' '),
                          rx_file_provider_name: details)

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
      query = query.where(matched_status: true)
    end

    query.sum(:program_revenue)
  end

  def claim_count(hospital_name, details, sort)
    if sort.present?
      if sort = "four_matched"
        RawFile.where(health_system_name: hospital_name, rx_file_provider_name: details,
                      matched_ndc_bin_pcn_state: true).where.not(paid_status: nil).count
      elsif sort = 'three_matched'
        RawFile.where(health_system_name: hospital_name, rx_file_provider_name: details,
                      matched_ndc_bin_pcn: true).where.not(paid_status: nil).count
      elsif sort = 'two_matched'
        RawFile.where(health_system_name: hospital_name, rx_file_provider_name: details,
                      matched_ndc_bin: true).where.not(paid_status: nil).count
      end
    else
       RawFile.where(health_system_name: hospital_name, rx_file_provider_name: details,
                     matched_status: true).where.not(paid_status: nil).count
    end
  end

  def contract_pharmacy_name_level_claim(hospital_name, details, sort)
    if sort.present?
      if sort = "four_matched"
        RawFile.where(health_system_name: hospital_name, contract_pharmacy_name: details,
                              matched_ndc_bin_pcn_state: true).where.not(paid_status: nil).count
      elsif sort = 'three_matched'
        RawFile.where(health_system_name: hospital_name, contract_pharmacy_name: details,
                              matched_ndc_bin_pcn: true).where.not(paid_status: nil).count
      elsif sort = 'two_matched'
        RawFile.where(health_system_name: hospital_name, contract_pharmacy_name: details,
                              matched_ndc_bin: true).where.not(paid_status: nil).count
      end
    else
       RawFile.where(health_system_name: hospital_name, contract_pharmacy_name: details,
                              matched_status: true).where.not(paid_status: nil).count
    end
  end

  def claim_cost(hospital_name, details, sort)
    query = RawFile.where(health_system_name: hospital_name, rx_file_provider_name: details).where.not(paid_status: nil)

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
      query = query.where(matched_status: true)
    end

    query.count
  end

  def contract_pharmacy_name_level_awp(details, sort)
     query = RawFile.where(health_system_name: params[:hospital_name].gsub('_', ' '),
                          contract_pharmacy_name: details)

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
      query = query.where(matched_status: true)
    end
    if query.present?
      ndc_records = query.map(&:ndc)
      AwpPrice.where(ndc: ndc_records).map { |price| price.awp.to_f }.sum
    end
  end

  def correctly_paid_claim(details, sort = nil)
    query = RawFile.where(health_system_name: params[:hospital_name].gsub('_', ' '),
                          rx_file_provider_name: details,
                          paid_status: 'correctly_paid')

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
      query = query.where(matched_status: true)
    end

    query.sum(:program_revenue).to_i
  end

  def total_program_revenue_pharmacy_group(details, sort = nil)
    query = RawFile.where(health_system_name: params[:hospital_name].gsub('_', ' '),
                          rx_file_provider_name: details).where.not(paid_status: nil)

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
      query = query.where(matched_status: true)
    end

    query.sum(:program_revenue).to_i
  end

  def contract_pharmacy_name_level_correct_paid_claim(details, sort)
    query = RawFile.where(health_system_name: params[:hospital_name].gsub('_', ' '),
                          contract_pharmacy_name: details,
                          paid_status: 'correctly_paid')

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
      query = query.where(matched_status: true)
    end

    query.sum(:program_revenue).to_i
  end

  def contract_pharmacy_name_level_under_paid(details, sort)
     query = RawFile.where(health_system_name: params[:hospital_name].gsub('_', ' '),
                          contract_pharmacy_name: details,
                          paid_status: 'under_paid')

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
      query = query.where(matched_status: true)
    end

    query.sum(:program_revenue).to_i
  end

  def over_paid_claim(details, sort)
    query = RawFile.where(health_system_name: params[:hospital_name].gsub('_', ' '),
                          rx_file_provider_name: details,
                          paid_status: 'over_paid')

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
      query = query.where(matched_status: true)
    end

    query.sum(:program_revenue).to_i
  end

  def contract_pharmacy_awp(hospital_name, details, sort)
    query = RawFile.where(health_system_name: hospital_name, rx_file_provider_name: details)
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
      query = query.where(matched_status: true)
    end

    all_records = query.map(&:ndc)
    AwpPrice.where(ndc: all_records).map { |price| price.awp.to_f }.sum
  end

  def under_paid_claim(details, sort)
    query = RawFile.where(health_system_name: params[:hospital_name].gsub('_', ' '),
                          rx_file_provider_name: details,
                          paid_status: 'under_paid')

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
      query = query.where(matched_status: true)
    end

    query.sum(:program_revenue).to_i
  end

  def uniq_contract_pharmacy(ndc_code, sort)
    query = RawFile.where(ndc: ndc_code)

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
      query = query.where(matched_status: true)
    end
    if query.present?
      ndc_records = query.map(&:ndc)
      AwpPrice.where(ndc: ndc_records).map { |price| price.awp.to_f }.sum
    end
  end

  def uniq_contract_pharmacy_claim(ndc_code, sort)
    query = RawFile.where(ndc: ndc_code)

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
      query = query.where(matched_status: true)
    end

    query.sum(:program_revenue)
  end


  private

  def flag_color(details)
    claim = details.claim_status
    case claim
    when nil
      'grey'
    when 'attempt_one'
      'green'
    when 'attempt_two'
      'yellow'
    when 'alternative'
      'red'
    end
  end

  def awp_price(pharmacy_record)
    awp_price = AwpPrice.where(ndc: pharmacy_record.ndc).first
    awp = awp_price.awp if awp_price.present?
  end

  def expected_reimbursement_matching(pharmacy_record)
    if pharmacy_record.paid_status.present?
      if MarketingPrice.where(ndc: pharmacy_record.ndc).where(matched_ndc_bin_pcn: true).present?
        MarketingPrice.where(ndc: pharmacy_record.ndc).where(matched_ndc_bin_pcn: true).first.reimbursement_per_quantity_dispensed * pharmacy_record.dispensed_quantity.to_f
      elsif MarketingPrice.where(ndc: pharmacy_record.ndc).where(matched_ndc_bin: true).present?
        MarketingPrice.where(ndc: pharmacy_record.ndc).where(matched_ndc_bin: true).first.reimbursement_per_quantity_dispensed * pharmacy_record.dispensed_quantity.to_f
      elsif MarketingPrice.where(ndc: pharmacy_record.ndc).where(matched_status: true).present?
         MarketingPrice.where(ndc: pharmacy_record.ndc).where(matched_status: true).first.reimbursement_per_quantity_dispensed * pharmacy_record.dispensed_quantity.to_f
      elsif InternalPrice.where(ndc: pharmacy_record.ndc).where(matched_ndc_bin_pcn: true).present?
          InternalPrice.where(ndc: pharmacy_record.ndc).where(matched_ndc_bin_pcn: true).first.reimbursement_per_quantity_dispensed * pharmacy_record.dispensed_quantity.to_f
      elsif InternalPrice.where(ndc: pharmacy_record.ndc).where(matched_ndc_bin: true).present?
         InternalPrice.where(ndc: pharmacy_record.ndc).where(matched_ndc_bin: true).first.reimbursement_per_quantity_dispensed * pharmacy_record.dispensed_quantity.to_f
      elsif InternalPrice.where(ndc: pharmacy_record.ndc).where(matched_status: true).present?
          InternalPrice.where(ndc: pharmacy_record.ndc).where(matched_status: true).first.reimbursement_per_quantity_dispensed * pharmacy_record.dispensed_quantity.to_f
      elsif StandardReferencePrice.where(ndc: pharmacy_record.ndc).where(matched_status: true).present?
          StandardReferencePrice.where(ndc: pharmacy_record.ndc).first.package_size * pharmacy_record.reimbursement_per_quantity_dispensed.to_f
      end
    else
      nil
    end
  end

  def reimbursement_spread(pharmacy_record)
    (expected_reimbursement_matching(pharmacy_record) - pharmacy_record.program_revenue) if pharmacy_record.paid_status.present?
  end

  def reimbursement_ndc_level_group_drug_name(details)
    RawFile.where(ndc: details).first.drug_name
  end

  def reimbursement_ndc_level_group_claims(details)
    RawFile.where(ndc: details).where.not(paid_status: nil).sum(:program_revenue).to_i
  end

  def reimbursement_ndc_level_group_awp(details)
    AwpPrice.where(ndc: details).map { |price| price.awp.to_f }.sum
  end

  def reimbursement_ndc_level_group_under_paid(details)
    RawFile.where(ndc: details, paid_status: 'under_paid').sum(:program_revenue).to_i
  end
end
