class UpdatePaidStatusJob < Struct.new(:id)
  # include Sidekiq::Worker

  def perform
    raw_data = RawFile.find(id)
    return unless raw_data.present?

    ndc_code = raw_data.ndc

    raw_sum = RawFile.where(ndc: ndc_code).pluck(:program_revenue, :quantity).transpose.map { |revenue, quantity| revenue.to_f / quantity.to_f unless quantity.to_i.zero? }.compact.sum
    marketing_sum = MarketingPrice.where(ndc: ndc_code).pluck(:claim_cost, :quantity_dispensed).transpose.map { |claim_cost, quantity_dispensed| claim_cost.to_f / quantity_dispensed.to_f unless quantity_dispensed.to_i.zero? }.compact.sum
    internal_sum = InternalPrice.where(ndc: ndc_code).pluck(:reimbursement_total, :quantity_dispensed).transpose.map { |reimbursement_total, quantity_dispensed| reimbursement_total.to_f / quantity_dispensed.to_f unless quantity_dispensed.to_i.zero? }.compact.sum

    # Determine the paid status
    if internal_sum == marketing_sum && raw_sum == internal_sum
      status = 'correctly paid'
    elsif internal_sum == marketing_sum && raw_sum > internal_sum
      status = 'over paid'
    elsif internal_sum == marketing_sum && raw_sum < internal_sum
      status = 'under paid'
    end

    RawFile.where(ndc: ndc_code).update_all(paid_status: status)
    MarketingPrice.where(ndc: ndc_code).update_all(paid_status: status)
    InternalPrice.where(ndc: ndc_code).update_all(paid_status: status)
  end
end
