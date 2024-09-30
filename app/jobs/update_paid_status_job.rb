class UpdatePaidStatusJob < Struct.new(:id)
  include Sidekiq::Worker

  def perform(record_id)
    raw_data = RawFile.find_by_id(record_id)
    InternalPrice.where.not(health_system_name: nil).where(ndc: nil, group: nil, state: nil, quantity_dispensed: nil, bin: nil).map(&:destroy)
    ndc_code = raw_data.ndc

  raw_sum = RawFile.where(ndc: ndc_code).pluck(:program_revenue).map(&:to_f).sum / RawFile.where(ndc: ndc_code).pluck(:dispensed_quantity).map(&:to_f).sum

  marketing_sum = nil
  internal_sum = nil

  # if MarketingPrice.where(ndc: ndc_code).where(ndc_bcn_pin_state: true).present?
  #   marketing_sum = MarketingPrice.where(ndc: ndc_code).where(ndc_bcn_pin_state: true).pluck(:claim_cost).map(&:to_f).sum / MarketingPrice.where(ndc: ndc_code).where(ndc_bcn_pin_state: true).pluck(:quantity_dispensed).map(&:to_f).sum
  if MarketingPrice.where(ndc: ndc_code).where(matched_ndc_bin_pcn: true).present?
    marketing_sum = MarketingPrice.where(ndc: ndc_code).where(matched_ndc_bin_pcn: true).pluck(:claim_cost).map(&:to_f).sum / MarketingPrice.where(ndc: ndc_code).where(matched_ndc_bin_pcn: true).pluck(:quantity_dispensed).map(&:to_f).sum
  elsif MarketingPrice.where(ndc: ndc_code).where(matched_ndc_bin: true).present?
    marketing_sum = MarketingPrice.where(ndc: ndc_code).where(matched_ndc_bin: true).pluck(:claim_cost).map(&:to_f).sum / MarketingPrice.where(ndc: ndc_code).where(matched_ndc_bin: true).pluck(:quantity_dispensed).map(&:to_f).sum
  elsif MarketingPrice.where(ndc: ndc_code).where(matched_status: true).present?
    marketing_sum = MarketingPrice.where(ndc: ndc_code).where(matched_status: true).pluck(:claim_cost).map(&:to_f).sum / MarketingPrice.where(ndc: ndc_code).where(matched_status: true).pluck(:quantity_dispensed).map(&:to_f).sum
  end

  if marketing_sum.nil?
    # if InternalPrice.where(ndc: ndc_code).where(ndc_bcn_pin_state: true).present?
    #   internal_sum = InternalPrice.where(ndc: ndc_code).where(ndc_bcn_pin_state: true).pluck(:reimbursement_total).map(&:to_f).sum / InternalPrice.where(ndc: ndc_code).where(ndc_bcn_pin_state: true).pluck(:quantity_dispensed).map(&:to_f).sum
    if InternalPrice.where(ndc: ndc_code).where(matched_ndc_bin_pcn: true).present?
      internal_sum = InternalPrice.where(ndc: ndc_code).where(matched_ndc_bin_pcn: true).pluck(:reimbursement_total).map(&:to_f).sum / InternalPrice.where(ndc: ndc_code).where(matched_ndc_bin_pcn: true).pluck(:quantity_dispensed).map(&:to_f).sum
    elsif InternalPrice.where(ndc: ndc_code).where(matched_ndc_bin: true).present?
      internal_sum = InternalPrice.where(ndc: ndc_code).where(matched_ndc_bin: true).pluck(:reimbursement_total).map(&:to_f).sum / InternalPrice.where(ndc: ndc_code).where(matched_ndc_bin: true).pluck(:quantity_dispensed).map(&:to_f).sum
    elsif InternalPrice.where(ndc: ndc_code).where(matched_status: true).present?
      internal_sum = InternalPrice.where(ndc: ndc_code).where(matched_status: true).pluck(:reimbursement_total).map(&:to_f).sum / InternalPrice.where(ndc: ndc_code).where(matched_status: true).pluck(:quantity_dispensed).map(&:to_f).sum
    end
  end

  # if marketing_sum.nil? && internal_sum.nil?

  # end

  final_sum = marketing_sum || internal_sum

    raw_three_percent = raw_sum * 0.03
    final_three_percent = final_sum * 0.03

    raw_lower_bound = raw_sum - raw_three_percent
    raw_upper_bound = raw_sum + raw_three_percent

    final_lower_bound = final_sum - final_three_percent
    final_upper_bound = final_sum + final_three_percent

    if final_lower_bound <= raw_upper_bound && final_upper_bound >= raw_lower_bound
      status =  "Correctly paid"
    elsif final_upper_bound < raw_lower_bound
      status =  "Underpaid"
    elsif final_lower_bound > raw_upper_bound
      status =  "Overpaid"
    end

      RawFile.where(ndc: ndc_code).update_all(paid_status: status)
      MarketingPrice.where(ndc: ndc_code).update_all(paid_status: status)
      InternalPrice.where(ndc: ndc_code).update_all(paid_status: status)
    end
  end
