class MatchNdcCodeJob
  include Sidekiq::Worker

  def perform
    raw_file_all_ndc = RawFile.all.map(&:ndc).uniq
    raw_file_all_ndc.each do |each_ndc|
      RawFile.where(ndc: each_ndc).update_all(ndc: each_ndc.gsub('-', ''))
    end
    process_internal_prices
    process_marketing_prices
    process_standard_reference_prices

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

  private

  def process_internal_prices
    internal_file_all_ndc = InternalPrice.all.map(&:ndc).uniq
    internal_file_all_ndc.each do |each_ndc|
      formatted_ndc = clean_and_format_ndc(each_ndc)
      InternalPrice.where(ndc: each_ndc).update_all(ndc: formatted_ndc) if formatted_ndc
    end
  end

  def process_marketing_prices
    marketing_file_all_ndc = MarketingPrice.all.map(&:ndc).uniq
    marketing_file_all_ndc.each do |each_ndc|
      formatted_ndc = clean_and_format_ndc(each_ndc)
      MarketingPrice.where(ndc: each_ndc).update_all(ndc: formatted_ndc) if formatted_ndc
    end
  end

  def process_standard_reference_prices
    standard_file_all_ndc = StandardReferencePrice.all.map(&:ndc).uniq
    standard_file_all_ndc.each do |each_ndc|
      formatted_ndc = clean_and_format_ndc(each_ndc)
      StandardReferencePrice.where(ndc: each_ndc).update_all(ndc: formatted_ndc) if formatted_ndc
    end
  end

  def clean_and_format_ndc(ndc)
    return if ndc.nil?

    cleaned_ndc = ndc.gsub('-', '').gsub('.0', '')

    if cleaned_ndc.length < 11
      cleaned_ndc = cleaned_ndc.rjust(11, '0')
    end

    cleaned_ndc
  end
end
