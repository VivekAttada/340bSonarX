# frozen_string_literal: true

class AwpFileImportJob
  include Sidekiq::Worker

  def perform(batch)
    return unless batch.present?

    AwpPrice.import_data(expected_headers, batch)
  end

  private

  def expected_headers
     %w[ndc awp_price package_size_quantity awp_per_package product_description abbreviated_desc awp_date
       bu_per_package pdp_awp_whole_sale_factor fdb_case_pack]
  end
end
