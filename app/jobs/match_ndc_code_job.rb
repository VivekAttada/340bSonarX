class MatchNdcCodeJob
  include Sidekiq::Worker

  def perform(health_system)
    sanitize_ndc(RawFile, health_system)
    sanitize_ndc(AwpPrice, nil)
    sanitize_ndc(InternalPrice, health_system)
    sanitize_ndc(MarketingPrice, health_system)
    sanitize_ndc(StandardReferencePrice, health_system)

    all_ndc_codes = InternalPrice.where(health_system_name: health_system).pluck(:ndc).uniq
    all_bin = InternalPrice.where(health_system_name: health_system).pluck(:bin).uniq
    all_states = InternalPrice.where(health_system_name: health_system).pluck(:state).uniq
    all_pcn = InternalPrice.where(health_system_name: health_system).pluck(:pcn).uniq

    RawFile.where(health_system_name: health_system).where(ndc: all_ndc_codes).in_batches.update_all(matched_status: true)
    RawFile.where(health_system_name: health_system).where(ndc: all_ndc_codes, primary_bin: all_bin, primary_pcn:all_pcn).in_batches.update_all(matched_ndc_bin_pcn: true)
    RawFile.where(health_system_name: health_system).where(ndc: all_ndc_codes, primary_bin: all_bin).in_batches.update_all(matched_ndc_bin: true)

    MarketingPrice.where(health_system_name: health_system).where(ndc: all_ndc_codes).in_batches.update_all(matched_status: true)
    MarketingPrice.where(health_system_name: health_system).where(ndc: all_ndc_codes, bin: all_bin, pcn:all_pcn).in_batches.update_all(matched_ndc_bin_pcn: true)
    MarketingPrice.where(health_system_name: health_system).where(ndc: all_ndc_codes, bin: all_bin).in_batches.update_all(matched_ndc_bin: true)

    all_matched_ndc = RawFile.where(health_system_name: health_system).where(matched_status: true).pluck(:ndc)
    all_ndc_bin_pcn_state = MarketingPrice.where(health_system_name: health_system).where(matched_ndc_bin_pcn_state: true).pluck(:ndc)
    all_ndc_bin_pcn = MarketingPrice.where(health_system_name: health_system).where(matched_ndc_bin_pcn: true).pluck(:ndc)
    all_ndc_bin = MarketingPrice.where(health_system_name: health_system).where(matched_ndc_bin: true).pluck(:ndc)
    InternalPrice.where(health_system_name: health_system).where(ndc: all_matched_ndc).in_batches.update_all(matched_status: true)
    InternalPrice.where(health_system_name: health_system).where(ndc: all_ndc_bin_pcn).in_batches.update_all(matched_ndc_bin_pcn: true)
    InternalPrice.where(health_system_name: health_system).where(ndc: all_ndc_bin).in_batches.update_all(matched_ndc_bin: true)
    StandardReferencePrice.where(health_system_name: health_system).where(ndc: all_matched_ndc).in_batches.update_all(matched_status: true)

   self.class.update_paid_status(health_system)
  end

  private

  def sanitize_ndc(klass, health_system = nil)
    query = klass.all
    query = query.where(health_system_name: health_system) if health_system.present?

    query.where.not(ndc: nil).find_each do |record|
      sanitized_ndc = record.ndc.gsub('-', '').gsub('.0', '')
      sanitized_ndc = sanitized_ndc.rjust(11, '0') if sanitized_ndc.length < 11
      record.update_column(:ndc, sanitized_ndc)
    end
  end

  def self.update_paid_status(health_system)
    RawFile.where(health_system_name: health_system).where(matched_status: true).find_in_batches(batch_size: 1000) do |batch|
      batch.each do |record|

        UpdatePaidStatusJob.perform_async(record.id, health_system)
      end
    end
  end
end
