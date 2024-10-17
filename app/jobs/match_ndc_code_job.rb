class MatchNdcCodeJob
  include Sidekiq::Worker

  def perform(health_system)
    sanitize_ndc(RawFile, health_system)
    sanitize_ndc(AwpPrice)
    sanitize_ndc(InternalPrice, health_system)
    sanitize_ndc(MarketingPrice, health_system)
    sanitize_ndc(StandardReferencePrice, health_system)

    all_ndc_codes = RawFile.where(health_system_name: health_system).pluck(:ndc).uniq
    all_bin = RawFile.where(health_system_name: health_system).pluck(:primary_bin).uniq
    all_pcn = RawFile.where(health_system_name: health_system).pluck(:primary_pcn).uniq

    # Update marketing matched status
    MarketingPrice.where(health_system_name: health_system, ndc: all_ndc_codes).in_batches.update_all(matched_status: true)
    marketing_matched_ndc = MarketingPrice.where(health_system_name: health_system, ndc: all_ndc_codes, matched_status: true).pluck(:ndc).uniq
    RawFile.where(ndc: marketing_matched_ndc).update_all(matched_status: true)

    MarketingPrice.where(health_system_name: health_system, ndc: all_ndc_codes, bin: all_bin, pcn: all_pcn).in_batches.update_all(matched_ndc_bin_pcn: true)
    marketing_matched_ndc_bin_pcn = MarketingPrice.where(health_system_name: health_system, ndc: all_ndc_codes, bin: all_bin, pcn: all_pcn).pluck(:ndc).uniq
    RawFile.where(ndc: marketing_matched_ndc_bin_pcn).update_all(matched_ndc_bin_pcn: true)

    MarketingPrice.where(health_system_name: health_system, ndc: all_ndc_codes, bin: all_bin).in_batches.update_all(matched_ndc_bin: true)
    marketing_matched_ndc_bin = MarketingPrice.where(health_system_name: health_system, ndc: all_ndc_codes, bin: all_bin).pluck(:ndc).uniq
    RawFile.where(ndc: marketing_matched_ndc_bin).update_all(matched_ndc_bin: true)

    # Update internal matched status
    InternalPrice.where(health_system_name: health_system, ndc: all_ndc_codes).in_batches.update_all(matched_status: true)
    internal_matched_ndc = InternalPrice.where(health_system_name: health_system, ndc: all_ndc_codes, matched_status: true).pluck(:ndc).uniq
    RawFile.where(ndc: internal_matched_ndc).update_all(matched_status: true)

    InternalPrice.where(health_system_name: health_system, ndc: all_ndc_codes, bin: all_bin, pcn: all_pcn).in_batches.update_all(matched_ndc_bin_pcn: true)
    internal_matched_ndc_bin_pcn = InternalPrice.where(health_system_name: health_system, ndc: all_ndc_codes, bin: all_bin, pcn: all_pcn).pluck(:ndc).uniq
    RawFile.where(ndc: internal_matched_ndc_bin_pcn).update_all(matched_ndc_bin_pcn: true)

    InternalPrice.where(health_system_name: health_system, ndc: all_ndc_codes, bin: all_bin).in_batches.update_all(matched_ndc_bin: true)
    internal_matched_ndc_bin = InternalPrice.where(health_system_name: health_system, ndc: all_ndc_codes, bin: all_bin).pluck(:ndc).uniq
    RawFile.where(ndc: internal_matched_ndc_bin).update_all(matched_ndc_bin: true)

    # Update standard reference matched status
    StandardReferencePrice.where(health_system_name: health_system, ndc: all_ndc_codes).in_batches.update_all(matched_status: true)
    standard_matched_ndc = StandardReferencePrice.where(health_system_name: health_system, ndc: all_ndc_codes).pluck(:ndc).uniq
    RawFile.where(ndc: standard_matched_ndc).update_all(matched_status: true)

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
    RawFile.where(health_system_name: health_system, matched_status: true).find_in_batches(batch_size: 1000) do |batch|
      batch.each do |record|
        UpdatePaidStatusJob.perform_async(record.id, health_system)
      end
    end
  end
end
