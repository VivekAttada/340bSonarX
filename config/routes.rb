# frozen_string_literal: true
  require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  root to: 'internal_price#index'

  post 'internal_file_bulk_upload', to: 'internal_price#internal_file_bulk_upload', as: 'internal_file_bulk_upload'
  post 'marketing_price_bulk_upload', to: 'internal_price#marketing_price_bulk_upload', as: 'marketing_file_bulk_upload'
  post 'raw_file_bulk_upload', to: 'internal_price#raw_file_bulk_upload', as: 'raw_file_bulk_upload'
  post 'awp_file_bulk_upload', to: 'internal_price#awp_file_bulk_upload', as: 'awp_file_bulk_upload'
  post 'standard_reference_price_file_bulk_upload', to: 'internal_price#standard_reference_price_file_bulk_upload', as: 'standard_reference_price_file_bulk_upload'

  get 'all_contract_pharmacies', to: 'internal_price#all_contract_pharmacies', as: 'all_contract_pharmacies'
  get 'dashboard', to: 'internal_price#dashboard', as: 'dashboard'
  get 'reimbursement', to: 'internal_price#reimbursement', as: 'reimbursement'
  get 'analytics', to: 'internal_price#analytics', as: 'analytics'
  get 'reimbursement_each_contract_pharmacy', to: 'internal_price#reimbursement_each_contract_pharmacy',
                                              as: 'reimbursement_each_contract_pharmacy'
  get 'claim_management', to: 'internal_price#claim_management', as: 'claim_management'
  get 'claim_each_contract_pharmacy', to: 'internal_price#claim_each_contract_pharmacy',
                                      as: 'claim_each_contract_pharmacy'

  post 'update_claim_status', to: 'internal_price#update_claim_status', as: 'update_claim_status'
  get 'marketing_price_sample_file', to: 'internal_price#marketing_price_sample_file'
  get 'internal_price_sample_file', to: 'internal_price#internal_price_sample_file'
  get 'standard_reference_price_sample_file', to: 'internal_price#standard_reference_price_sample_file'
end
