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

  # def contract_pharmacy_reimbursement(details)
  #   ndc = RawFile.where(rx_file_provider_name: details, matched_status: true).all.map(&:ndc)
  #   AwpPrice.where(ndc: ndc).sum(:awp)
  # end

  def contract_pharmacy_reimbursement(details, sort)
    query = RawFile.where(rx_file_provider_name: details).where.not(paid_status: nil)

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

  # def contract_pharmacies_revenue(details)
  #   RawFile.where(health_system_name: params[:hospital_name], matched_status: true, rx_file_provider_name: details)
  #          .sum(:program_revenue)
  # end

  def contract_pharmacies_revenue(details, sort)
    query = RawFile.where(health_system_name: params[:hospital_name],
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

  def claim_count(details, sort)
    if sort.present?
      if sort = "four_matched"
        RawFile.where(rx_file_provider_name: details,
                              matched_ndc_bin_pcn_state: true).where.not(paid_status: nil).count
      elsif sort = 'three_matched'
        RawFile.where(rx_file_provider_name: details,
                              matched_ndc_bin_pcn: true).where.not(paid_status: nil).count
      elsif sort = 'two_matched'
        RawFile.where(rx_file_provider_name: details,
                              matched_ndc_bin: true).where.not(paid_status: nil).count
      end
    else
       RawFile.where(rx_file_provider_name: details,
                              matched_status: true).where.not(paid_status: nil).count
    end
  end

  # def claim_cost(details)
  #   RawFile.where(rx_file_provider_name: details,
  #                         matched_status: true).where.not(paid_status: nil).count
  # end

  def claim_cost(details, sort)
    query = RawFile.where(rx_file_provider_name: details).where.not(paid_status: nil)

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


  # def correctly_paid_claim(details)
  #   RawFile.where(health_system_name: params[:hospital_name], rx_file_provider_name: details,
  #                         matched_status: true, paid_status: 'correctly paid').sum(:program_revenue).to_i
  # end

  def correctly_paid_claim(details, sort = nil)
    query = RawFile.where(health_system_name: params[:hospital_name],
                          rx_file_provider_name: details,
                          paid_status: 'Correctly paid')

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


  # def over_paid_claim(details)
  #   calculate_revenue(details, paid_status: 'over paid')
  # end

  def over_paid_claim(details, sort)
    query = RawFile.where(health_system_name: params[:hospital_name],
                          rx_file_provider_name: details,
                          paid_status: 'Overpaid')

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


  # def contract_pharmacy_awp(details)
  #   all_records = RawFile.where(rx_file_provider_name: details, matched_status: true).map(&:ndc)
  #   AwpPrice.where(ndc: all_records).sum(:awp)
  # end

  def contract_pharmacy_awp(details, sort)
    query = RawFile.where(rx_file_provider_name: details)
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


  # def under_paid_claim(details)
  #   calculate_revenue(details, paid_status: 'under paid')
  # end

  def under_paid_claim(details, sort)
    query = RawFile.where(health_system_name: params[:hospital_name],
                          rx_file_provider_name: details,
                          paid_status: 'Underpaid')

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

  # def uniq_contract_pharmacy(ndc_code)
  #   AwpPrice.where(ndc: ndc_code).sum(:awp)
  # end

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


  # def uniq_contract_pharmacy_claim(ndc_code)
  #   RawFile.where(ndc: ndc_code).sum(:program_revenue)
  # end

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

  # def calculate_revenue(details, paid_status: nil, not_paid_status: true)
  #   query = RawFile.where(health_system_name: params[:hospital_name], rx_file_provider_name: details,
  #                         matched_status: true)
  #   query = query.where(paid_status: paid_status) if paid_status
  #   query = query.where.not(paid_status: nil) if not_paid_status
  #   query.sum(:program_revenue).to_i
  # end

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
      end
    else
      nil
    end
  end

  def reimbursement_spread(pharmacy_record)
    (expected_reimbursement_matching(pharmacy_record) - pharmacy_record.program_revenue) if pharmacy_record.paid_status.present?
  end
end
