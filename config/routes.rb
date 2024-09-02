# frozen_string_literal: true

Rails.application.routes.draw do
  root 'internal_price#index'
  post '/internal_file_bulk_upload' => 'internal_price#internal_file_bulk_upload', as: 'internal_file_bulk_upload'
  post '/marketing_price_bulk_upload' => 'internal_price#marketing_price_bulk_upload', as: 'marketing_file_bulk_upload'
  post '/raw_file_bulk_upload' => 'internal_price#raw_file_bulk_upload', as: 'raw_file_bulk_upload'
  get '/all_contract_pharmacies' => 'internal_price#all_contract_pharmacies', as: 'all_contract_pharmacies'
  get '/dashboard' => 'internal_price#dashboard', as: 'dashboard'
  get '/reimbursement' => 'internal_price#reimbursement', as: 'reimbursement'
  get '/claim_management' => 'internal_price#claim_management', as: 'claim_management'
  get '/analytics' => 'internal_price#analytics', as: 'analytics'
  get '/each_contract_pharmacy' => 'internal_price#each_contract_pharmacy', as: 'each_contract_pharmacy'
end
