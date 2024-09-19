# frozen_string_literal: true

class AwpFileImportJob
  include Sidekiq::Worker

  def perform(batch)
    return unless batch.present?

    AwpPrice.import_data(expected_headers, batch)
  end

  private

  def expected_headers
      %w[product_description ndc abbreviated_desc awp awp_date bu_per_package
       fdb_awp_wholesale_factor fdb_case_pack fdb_package_size_quantity awp_per_package]
  end
end
