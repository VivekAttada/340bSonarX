class MatchNdcCodeJob
  def perform
    all_ndc_codes = InternalPrice.pluck(:ndc_code)
    RawFile.where(ndc: all_ndc_codes).update_all(matched_status: true)
    MarketingPrice.where(ndc: all_ndc_codes).update_all(matched_status: true)
    all_matched_ndc = RawFile.where(matched_status: true).pluck(:ndc)
    InternalPrice.where(ndc: all_matched_ndc).update_all(matched_status: true)

    self.class.update_paid_status
  end

  def self.update_paid_status
    matched_records = RawFile.where(matched_status: true).pluck(:id)
    matched_records.each do |record_id|
      Delayed::Job.enqueue UpdatePaidStatusJob.new(record_id)
    end
  end
end
