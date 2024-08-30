Rails.application.routes.draw do
  root "internal_price#index"
  post '/internal_file_bulk_upload' => 'internal_price#internal_file_bulk_upload', as: 'internal_file_bulk_upload'
  post '/marketing_price_bulk_upload' => 'internal_price#marketing_price_bulk_upload', as: 'marketing_file_bulk_upload'
  post '/raw_file_bulk_upload' => 'internal_price#raw_file_bulk_upload', as: 'raw_file_bulk_upload'
end
