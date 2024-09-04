# frozen_string_literal: true

class AwpFileImportJob
  def initialize(batch)
    @batch = batch
  end

  def perform
    return unless @batch.present?

    AwpPrice.import_data(expected_headers, @batch)
  end

  private

  def expected_headers
    %w[ndc awp_price package_size_quantity awp_per_package]
  end
end
