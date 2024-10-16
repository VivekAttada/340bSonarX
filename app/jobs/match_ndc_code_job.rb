class MatchNdcCodeJob
  include Sidekiq::Worker

  def perform(health_system)
    sanitize_ndc(RawFile, health_system)
    sanitize_ndc(AwpPrice, nil)
    sanitize_ndc(InternalPrice, health_system)
    sanitize_ndc(MarketingPrice, health_system)
    sanitize_ndc(StandardReferencePrice, health_system)

    all_ndc_codes = RawFile.where(health_system_name: health_system).pluck(:ndc).uniq
    all_bin = RawFile.where(health_system_name: health_system).pluck(:primary_bin).uniq
    all_pcn = RawFile.where(health_system_name: health_system).pluck(:primary_pcn).uniq

    marketing_ndc = MarketingPrice.where(health_system_name: health_system).where(ndc: all_ndc_codes).in_batches.update_all(matched_status: true)
    RawFile.where(ndc: marketing_ndc.pluck(:ndc).uniq).update_all(matched_status: true) if marketing_ndc.present? && marketing_ndc > 0
    marketing_ndc_bin_pcn = MarketingPrice.where(health_system_name: health_system).where(ndc: all_ndc_codes, bin: all_bin, pcn:all_pcn).in_batches.update_all(matched_ndc_bin_pcn: true)
    RawFile.where(ndc: marketing_ndc_bin_pcn.pluck(:ndc).uniq).update_all(matched_ndc_bin_pcn: true) if marketing_ndc_bin_pcn.present? && marketing_ndc_bin_pcn > 0
    marketing_ndc_bin = MarketingPrice.where(health_system_name: health_system).where(ndc: all_ndc_codes, bin: all_bin).in_batches.update_all(matched_ndc_bin: true)
    RawFile.where(ndc: marketing_ndc_bin.pluck(:ndc).uniq).update_all(matched_ndc_bin: true) if marketing_ndc_bin.present? && marketing_ndc_bin > 0

    internal_ndc = InternalPrice.where(health_system_name: health_system).where(ndc: all_ndc_codes).in_batches.update_all(matched_status: true)
    RawFile.where(ndc: internal_ndc.pluck(:ndc).uniq).update_all(matched_status: true) if internal_ndc.present? && internal_ndc > 0
    internal_ndc_bin_pcn = InternalPrice.where(health_system_name: health_system).where(ndc: all_ndc_codes, bin: all_bin, pcn:all_pcn).in_batches.update_all(matched_ndc_bin_pcn: true)
    RawFile.where(ndc: internal_ndc_bin_pcn.map(&:ndc).uniq).update_all(matched_ndc_bin_pcn: true) if internal_ndc_bin_pcn.present? && internal_ndc_bin_pcn > 0
    internal_ndc_bin = InternalPrice.where(health_system_name: health_system).where(ndc: all_ndc_codes, bin: all_bin).in_batches.update_all(matched_ndc_bin: true)
    RawFile.where(ndc: internal_ndc_bin.pluck(:ndc).uniq).update_all(matched_ndc_bin: true) if internal_ndc_bin.present? && internal_ndc_bin > 0

    standard_ndc = StandardReferencePrice.where(health_system_name: health_system).where(ndc: all_ndc_codes).in_batches.update_all(matched_status: true)
    RawFile.where(ndc: standard_ndc.pluck(:ndc).uniq).update_all(matched_status: true) if standard_ndc.present? && standard_ndc > 0

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
