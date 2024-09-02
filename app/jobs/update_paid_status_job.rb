# frozen_string_literal: true

UpdatePaidStatusJob = Struct.new(:id) do
  def perform
    raw_data = RawFile.find_by_id(id)
    # raw_value = raw_data.program_revenue.to_f / raw_data.quantity.to_f
    raw_value = RawFile.where(ndc: raw_data.ndc).map(&:program_revenue).sum.to_i / RawFile.where(ndc: raw_data.ndc).map(&:quantity).sum.to_i
    # marketing_data = MarketingPrice.find_by_id(id)
    marketing_value = MarketingPrice.where(ndc: raw_data.ndc).map(&:claim_cost).sum.to_i / MarketingPrice.where(ndc: raw_data.ndc).map(&:quantity_dispensed).sum.to_i
    # marketing_value = marketing_data.claim_cost.to_f / marketing_data.quantity_dispensed.to_f
    # internal_data = InternalPrice.find_by_id(id)
    internal_value = InternalPrice.where(ndc: raw_data.ndc).map(&:reimbursement_total).sum.to_i / InternalPrice.where(ndc: raw_data.ndc).map(&:quantity_dispensed).sum.to_i
    # internal_value = internal_data.reimbursement_total.to_f / internal_data.quantity_dispensed.to_f

    if internal_value == marketing_value && raw_value == internal_value
      RawFile.where(ndc: raw_data.ndc).update(paid_status: 'correctly paid')
      MarketingPrice.where(ndc: raw_data.ndc).update(paid_status: 'correctly paid')
      InternalPrice.where(ndc: raw_data.ndc).update(paid_status: 'correctly paid')
      # RawFile.where(ndc: raw_data.ndc).update(paid_status: "correctlty paid")
    elsif internal_value == marketing_value && raw_value > internal_value
      RawFile.where(ndc: raw_data.ndc).update(paid_status: 'over paid')
      MarketingPrice.where(ndc: raw_data.ndc).update(paid_status: 'over paid')
      InternalPrice.where(ndc: raw_data.ndc).update(paid_status: 'over paid')
    elsif internal_value == marketing_value && raw_value < internal_value
      RawFile.where(ndc: raw_data.ndc).update(paid_status: 'under paid')
      MarketingPrice.where(ndc: raw_data.ndc).update(paid_status: 'under paid')
      InternalPrice.where(ndc: raw_data.ndc).update(paid_status: 'under paid')
    end
  end
end
