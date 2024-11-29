class UpdatePaidStatusJob < Struct.new(:id)
  include Sidekiq::Worker

  def perform(record_id, health_system)
    raw_data = RawFile.find_by_id(record_id)
    InternalPrice.where(health_system_name: health_system).where(ndc: nil, group: nil, state: nil, quantity_dispensed: nil, bin: nil).map(&:destroy)
    ndc_code = raw_data.ndc

  raw_sum = RawFile.where(health_system_name: health_system, ndc: ndc_code).pluck(:program_revenue).map(&:to_f).sum / RawFile.where(health_system_name: health_system, ndc: ndc_code).pluck(:dispensed_quantity).map(&:to_f).sum

  marketing_sum = nil
  internal_sum = nil

  marketing_prices = MarketingPrice.where(health_system_name: health_system).where(ndc: ndc_code)

  if marketing_prices.where(matched_ndc_bin_pcn: true).present?
    marketing_sum = marketing_prices.where(matched_ndc_bin_pcn: true).pluck(:claim_cost).map(&:to_f).sum / marketing_prices.where(matched_ndc_bin_pcn: true).pluck(:quantity_dispensed).map(&:to_f).sum
  elsif marketing_prices.where(matched_ndc_bin: true).present?
    marketing_sum = marketing_prices.where(matched_ndc_bin: true).pluck(:claim_cost).map(&:to_f).sum / marketing_prices.where(matched_ndc_bin: true).pluck(:quantity_dispensed).map(&:to_f).sum
  elsif marketing_prices.where(matched_status: true).present?
    marketing_sum = marketing_prices.where(matched_status: true).pluck(:claim_cost).map(&:to_f).sum / marketing_prices.where(matched_status: true).pluck(:quantity_dispensed).map(&:to_f).sum
  end

  if marketing_sum.nil?
    internal_prices = InternalPrice.where(health_system_name: health_system).where(ndc: ndc_code)
    if internal_prices.where(matched_ndc_bin_pcn: true).present?
      internal_sum = internal_prices.where(matched_ndc_bin_pcn: true).pluck(:reimbursement_total).map(&:to_f).sum / internal_prices.where(matched_ndc_bin_pcn: true).pluck(:quantity_dispensed).map(&:to_f).sum
    elsif internal_prices.where(matched_ndc_bin: true).present?
      internal_sum = InternalPrice.where(ndc: ndc_code).where(matched_ndc_bin: true).pluck(:reimbursement_total).map(&:to_f).sum / internal_prices.where(matched_ndc_bin: true).pluck(:quantity_dispensed).map(&:to_f).sum
    elsif internal_prices.where(matched_status: true).present?
      internal_sum = internal_prices.where(matched_status: true).pluck(:reimbursement_total).map(&:to_f).sum / internal_prices.where(matched_status: true).pluck(:quantity_dispensed).map(&:to_f).sum
    end
  end

  if marketing_sum.nil? && internal_sum.nil?
    standard_prices = StandardReferencePrice.where(health_system_name: health_system).where(ndc: ndc_code)
    standard_reference_sum = (standard_prices.where(matched_status: true).pluck(:package_size).map(&:to_f).sum) * (standard_prices.where(matched_status: true).pluck(:reimbursement_per_quantity_dispensed).map(&:to_f).sum)
  end

  final_sum = marketing_sum || internal_sum || standard_reference_sum
    raw_three_percent = raw_sum * 0.03
    raw_lower_bound = raw_sum - raw_three_percent
    raw_upper_bound = raw_sum + raw_three_percent

    if final_sum.between?(raw_lower_bound, raw_upper_bound)
      status =  "correctly_paid"
    elsif raw_lower_bound < final_sum
      status =  "under_paid"
    elsif raw_upper_bound > final_sum
      status =  "over_paid"
    end

      RawFile.where(health_system_name: health_system).where(ndc: ndc_code).update_all(paid_status: status)
      MarketingPrice.where(health_system_name: health_system).where(ndc: ndc_code).update_all(paid_status: status)
      InternalPrice.where(health_system_name: health_system).where(ndc: ndc_code).update_all(paid_status: status)
    end
  end
