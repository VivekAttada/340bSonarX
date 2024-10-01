class MatchNdcCodeJob
  include Sidekiq::Worker

  def perform
    raw_file_all_ndc = RawFile.all.map(&:ndc).uniq
    raw_file_all_ndc.each do |each_ndc|
      RawFile.where(ndc: each_ndc).update_all(ndc: each_ndc.gsub('-', ''))
    end

    awp_file_all_ndc = AwpPrice.all.map(&:ndc).uniq
    awp_file_all_ndc.each do |each_ndc|
      next if each_ndc.nil?
      AwpPrice.where(ndc: each_ndc).update_all(ndc: each_ndc.gsub('-', '').gsub('.0', ''))
    end

    internal_file_all_ndc = InternalPrice.all.map(&:ndc).uniq
    internal_file_all_ndc.each do |each_ndc|
      next if each_ndc.nil?
      InternalPrice.where(ndc: each_ndc).update_all(ndc: each_ndc.gsub('-', '').gsub('.0', ''))
    end

    marketing_file_all_ndc = MarketingPrice.all.map(&:ndc).uniq
    marketing_file_all_ndc.each do |each_ndc|
      next if each_ndc.nil?
      MarketingPrice.where(ndc: each_ndc).update_all(ndc: each_ndc.gsub('-', '').gsub('.0', ''))
    end

    standard_file_all_ndc = StandardReferencePrice.all.map(&:ndc).uniq
    standard_file_all_ndc.each do |each_ndc|
      next if each_ndc.nil?
      StandardReferencePrice.where(ndc: each_ndc).update_all(ndc: each_ndc.gsub('-', '').gsub('.0', ''))
    end

    all_ndc_codes = InternalPrice.pluck(:ndc)
    all_bin = InternalPrice.pluck(:bin)
    all_states = InternalPrice.pluck(:state)
    all_pcn = InternalPrice.pluck(:pcn)

    RawFile.where(ndc: all_ndc_codes).in_batches.update_all(matched_status: true)
    # RawFile.where(ndc: all_ndc_codes, primary_bin: all_bin, state: all_states, primary_pcn:all_pcn).in_batches.update_all(matched_ndc_bin_pcn_state: true)
    RawFile.where(ndc: all_ndc_codes, primary_bin: all_bin, primary_pcn:all_pcn).in_batches.update_all(matched_ndc_bin_pcn: true)
    RawFile.where(ndc: all_ndc_codes, primary_bin: all_bin).in_batches.update_all(matched_ndc_bin: true)

    MarketingPrice.where(ndc: all_ndc_codes).in_batches.update_all(matched_status: true)
    # MarketingPrice.where(ndc: all_ndc_codes, bin: all_bin, state: all_states, pcn:all_pcn).in_batches.update_all(matched_ndc_bin_pcn_state: true)
    MarketingPrice.where(ndc: all_ndc_codes, bin: all_bin, pcn:all_pcn).in_batches.update_all(matched_ndc_bin_pcn: true)
    MarketingPrice.where(ndc: all_ndc_codes, bin: all_bin).in_batches.update_all(matched_ndc_bin: true)


    all_matched_ndc = RawFile.where(matched_status: true).pluck(:ndc)
    all_ndc_bin_pcn_state = MarketingPrice.where(matched_ndc_bin_pcn_state: true).pluck(:ndc)
    all_ndc_bin_pcn = MarketingPrice.where(matched_ndc_bin_pcn: true).pluck(:ndc)
    all_ndc_bin = MarketingPrice.where(matched_ndc_bin: true).pluck(:ndc)
    InternalPrice.where(ndc: all_matched_ndc).in_batches.update_all(matched_status: true)
    # InternalPrice.where(ndc: all_ndc_bin_pcn_state).in_batches.update_all(matched_ndc_bin_pcn_state: true)
    InternalPrice.where(ndc: all_ndc_bin_pcn).in_batches.update_all(matched_ndc_bin_pcn: true)
    InternalPrice.where(ndc: all_ndc_bin).in_batches.update_all(matched_ndc_bin: true)
    # RawFile.where(ndc: all_ndc_bin_pcn_state).in_batches.update_all(matched_ndc_bin_pcn_state: true)
    # RawFile.where(ndc: all_ndc_bin_pcn).in_batches.update_all(matched_ndc_bin_pcn: true)
    # RawFile.where(ndc: all_ndc_bin).in_batches.update_all(matched_ndc_bin: true)
    StandardReferencePrice.where(ndc: all_matched_ndc).update_all(matched_status: true)

   self.class.update_paid_status
  end

  def self.update_paid_status
    RawFile.where(matched_status: true).find_in_batches(batch_size: 1000) do |batch|
      batch.each do |record|

        UpdatePaidStatusJob.perform_async(record.id)
      end
    end
  end
end
