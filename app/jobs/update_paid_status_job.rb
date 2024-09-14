class UpdatePaidStatusJob < Struct.new(:id)
  include Sidekiq::Worker

  def perform
    raw_data = RawFile.find(id)
    return unless raw_data.present?

    ndc_code = raw_data.ndc

    raw_sum = RawFile.where(ndc: ndc_code).pluck(:program_revenue).map(&:to_f).sum / RawFile.where(ndc: ndc_code).pluck(:quantity).map(&:to_f).sum
    marketing_sum = MarketingPrice.where(ndc: ndc_code).pluck(:claim_cost).map(&:to_f).sum / MarketingPrice.where(ndc: ndc_code).pluck(:quantity_dispensed).map(&:to_f).sum
    internal_sum = InternalPrice.where(ndc: ndc_code).pluck(:reimbursement_total).map(&:to_f).sum / InternalPrice.where(ndc: ndc_code).pluck(:quantity_dispensed).map(&:to_f).sum

    tolerance_percentage = 3
    internal_marketing_tolerance = internal_sum * (tolerance_percentage / 100.0)
    raw_internal_tolerance = internal_sum * (tolerance_percentage / 100.0)

    if within_tolerance?(internal_sum, marketing_sum, tolerance_percentage) && within_tolerance?(raw_sum, internal_sum, tolerance_percentage)
      status = 'correctly paid'
    elsif within_tolerance?(internal_sum, marketing_sum, tolerance_percentage) && (raw_sum > internal_sum + raw_internal_tolerance)
      status = 'over paid'
    elsif within_tolerance?(internal_sum, marketing_sum, tolerance_percentage) && (raw_sum < internal_sum - raw_internal_tolerance)
      status = 'under paid'
    else
      status = 'status unclear'
    end

    RawFile.where(ndc: ndc_code).update_all(paid_status: status)
    MarketingPrice.where(ndc: ndc_code).update_all(paid_status: status)
    InternalPrice.where(ndc: ndc_code).update_all(paid_status: status)
  end

  private

  def within_tolerance?(value1, value2, tolerance_percentage = 3)
    tolerance = value1 * tolerance_percentage / 100.0
    (value1 - tolerance..value1 + tolerance).include?(value2)
  end
end
