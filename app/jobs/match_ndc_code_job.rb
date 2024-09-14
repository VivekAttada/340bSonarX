class MatchNdcCodeJob
  include Sidekiq::Worker

  def perform
    vv = RawFile.all.map(&:ndc).uniq
    vv.each do |each_ndc|
      RawFile.where(ndc: each_ndc).update_all(ndc: each_ndc.gsub('-', ''))
     end

    all_ndc_codes = InternalPrice.pluck(:ndc)

    RawFile.where(ndc: all_ndc_codes).in_batches.update_all(matched_status: true)
    MarketingPrice.where(ndc: all_ndc_codes).in_batches.update_all(matched_status: true)

    all_matched_ndc = RawFile.where(matched_status: true).pluck(:ndc)
    InternalPrice.where(ndc: all_matched_ndc).in_batches.update_all(matched_status: true)

    self.class.update_paid_status
  end

  def self.update_paid_status
    RawFile.where(matched_status: true).find_in_batches(batch_size: 1000) do |batch|
      batch.each do |record|

        Delayed::Job.enqueue UpdatePaidStatusJob.new(record.id)
      end
    end
  end
end
