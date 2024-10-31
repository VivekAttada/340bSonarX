# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_09_20_054511) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "awp_prices", force: :cascade do |t|
    t.string "ndc"
    t.string "awp"
    t.string "fdb_package_size_quantity"
    t.string "awp_per_package"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "product_description"
    t.string "abbreviated_desc"
    t.datetime "awp_date"
    t.string "bu_per_package"
    t.string "fdb_awp_wholesale_factor"
    t.string "fdb_case_pack"
  end

  create_table "care_providers", id: :serial, force: :cascade do |t|
    t.string "provider_first_name", limit: 255, null: false
    t.string "provider_last_name", limit: 255, null: false
    t.string "dea_number", limit: 255, null: false
    t.string "npin_number", limit: 255, null: false
    t.date "start_date", null: false
    t.date "term_date", null: false
    t.string "dept_name", limit: 255, null: false
    t.string "dept_id", limit: 255, null: false
    t.string "address", limit: 255, null: false
    t.string "city", limit: 255, null: false
    t.string "state", limit: 255, null: false
    t.string "zip", limit: 255, null: false
    t.string "n340_b_id", limit: 255, null: false
    t.string "n340_b_name", limit: 255, null: false
    t.string "n340_b_address", limit: 255, null: false
    t.string "n340_b_status", limit: 255, null: false
    t.string "primary_contact", limit: 255, null: false
    t.string "n340_b_start_date", limit: 255, null: false
    t.string "status", limit: 255, default: "enrolled", null: false
    t.float "longitude", null: false
    t.float "latitude", null: false
    t.string "location_type", limit: 255, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "careprovider_locations", id: :serial, force: :cascade do |t|
    t.integer "careprovider_id", null: false
    t.string "longitude", limit: 255, null: false
    t.string "latitude", limit: 255, null: false
    t.string "location_type", limit: 255
    t.float "bbox", array: true
    t.string "mapbox_id", limit: 255
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "drugs", id: :serial, force: :cascade do |t|
    t.string "specialty_drug_list_therapy_class", limit: 255, null: false
    t.string "drug_label_name", limit: 255, null: false
    t.string "generic_name", limit: 255, null: false
    t.string "ndc_11_digit", limit: 255, null: false
    t.string "brand_or_generic", limit: 255, null: false
    t.date "add_date", null: false
    t.string "ldd", limit: 255
    t.string "price", limit: 255, null: false
    t.string "status", limit: 255, default: "enrolled", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "internal_prices", force: :cascade do |t|
    t.string "ndc"
    t.string "bin"
    t.string "pcn"
    t.string "group"
    t.string "state"
    t.float "reimbursement_total"
    t.float "quantity_dispensed"
    t.datetime "transaction_date", precision: nil
    t.boolean "matched_status", default: false
    t.string "health_system_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "paid_status"
    t.string "claim_status"
    t.float "reimbursement_per_quantity_dispensed"
    t.boolean "matched_ndc_bin_pcn_state"
    t.boolean "matched_ndc_bin_pcn"
    t.boolean "matched_ndc_bin"
  end

  create_table "marketing_prices", force: :cascade do |t|
    t.string "ndc"
    t.string "bin"
    t.string "pcn"
    t.string "group"
    t.string "state"
    t.float "claim_cost"
    t.float "quantity_dispensed"
    t.boolean "matched_status", default: false
    t.string "health_system_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "paid_status"
    t.string "claim_status"
    t.string "zip_code"
    t.float "reimbursement_per_quantity_dispensed"
    t.boolean "matched_ndc_bin_pcn_state"
    t.boolean "matched_ndc_bin_pcn"
    t.boolean "matched_ndc_bin"
  end

  create_table "members", id: :serial, force: :cascade do |t|
    t.string "organization_number", limit: 255
    t.string "organization_name", limit: 255
    t.string "member_middle_name", limit: 255
    t.string "carrier_number", limit: 255
    t.string "carrier_name", limit: 255
    t.string "account_number", limit: 255
    t.string "account_name", limit: 255
    t.string "group_number", limit: 255
    t.string "group_name", limit: 255
    t.string "bin", limit: 255
    t.string "pcn", limit: 255
    t.string "submitted_group_number", limit: 255
    t.string "submitted_cardholder_id", limit: 255
    t.string "cardholder_id", limit: 255, null: false
    t.string "insurance_cardholder_last_name", limit: 255
    t.string "insurance_cardholder_first_name", limit: 255
    t.date "cardholder_dob"
    t.string "alternate_member_id", limit: 255
    t.string "external_member_id", limit: 255
    t.string "member_person_code", limit: 255
    t.string "member_relationship_code", limit: 255
    t.string "member_last_name", limit: 255
    t.string "member_first_name", limit: 255
    t.date "member_dob"
    t.string "member_gender", limit: 255
    t.string "member_address_1", limit: 255
    t.string "member_address_2", limit: 255
    t.string "member_city", limit: 255
    t.string "member_state", limit: 255
    t.string "member_zip", limit: 255, null: false
    t.string "member_phone", limit: 255, null: false
    t.string "member_tag", limit: 255
    t.string "member_status", limit: 255, default: "enrolled"
    t.integer "org_id", null: false
    t.float "longitude", null: false
    t.float "latitude", null: false
    t.string "location_type", limit: 255, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "org_assigns", id: :serial, force: :cascade do |t|
    t.integer "org_id", null: false
    t.integer "user_id", null: false
    t.string "user_role", limit: 255, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "org_careproviders", id: :serial, force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "careprovider_id", null: false
    t.boolean "available", null: false
  end

  create_table "organization_drugs", id: :serial, force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "drug_id", null: false
    t.boolean "available", null: false
  end

  create_table "organizations", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "status", limit: 255, default: "enrolled", null: false
    t.string "image", limit: 255
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.integer "unavailable_drugs", array: true
    t.integer "unavailable_care_providers", array: true
  end

  create_table "raw_claims", id: :integer, default: nil, force: :cascade do |t|
    t.string "id_340b"
    t.string "contract_pharmacy_name"
    t.string "pharmacy_npi"
    t.string "rx"
    t.string "ndc"
    t.string "ndc_no_dash"
    t.string "drug_name"
    t.string "manufacturer"
    t.string "drug_class"
    t.integer "packages_dispensed"
    t.integer "mdq"
    t.date "rx_written_date"
    t.date "dispensed_date"
    t.integer "fill"
    t.integer "dispensed_qty"
    t.integer "days_supply"
    t.decimal "program_revenue"
    t.decimal "patient_paid"
    t.decimal "est_340b_cost"
    t.decimal "admin_fee"
    t.decimal "dispensing_fee"
    t.decimal "est_entity_net_savings"
    t.string "transaction_status"
    t.string "ticket"
    t.string "reprocessing_reason"
    t.string "transaction"
    t.string "patient_group"
    t.string "qualification_method"
    t.string "external_eligibility_reason"
    t.string "external_claim_rejection_reason"
    t.string "prescriber_name"
    t.string "prescriber_npi"
    t.string "card_holder"
    t.string "primary_bin"
    t.string "primary_pcn"
    t.string "primary_group"
    t.string "primary_payer_name"
    t.string "primary_plan_name"
    t.string "primary_plan_type"
    t.string "primary_benefit_plan_name"
    t.string "voucher"
    t.string "voucher_pharmacy_id"
    t.string "voucher_export_model"
    t.string "invoice"
    t.string "invoice_export_model"
    t.integer "qty_allocated"
    t.string "last_allocation_type"
    t.date "last_allocation_date"
    t.integer "unreplenished_qty"
    t.string "rx_file_provider_name"
    t.string "submission_clarification_code"
    t.date "orderable_date"
    t.integer "order_delay"
    t.integer "order_attempts"
    t.boolean "matched_status"
    t.string "health_system_name"
  end

  create_table "raw_files", force: :cascade do |t|
    t.string "contract_pharmacy_name"
    t.string "ndc"
    t.float "program_revenue"
    t.string "dispensed_quantity"
    t.string "pharmacy_npi"
    t.string "health_system_name"
    t.boolean "matched_status"
    t.string "paid_status"
    t.string "rx_file_provider_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "claim_status"
    t.date "processed_date"
    t.string "three_forty_b_id"
    t.string "rx"
    t.string "drug_name"
    t.string "manufacturer"
    t.string "drug_class"
    t.integer "packages_dispensed"
    t.integer "mdq"
    t.date "rx_written_date"
    t.date "dispensed_date"
    t.string "fill"
    t.integer "patient_paid"
    t.integer "admin_fee"
    t.integer "dispensing_fee"
    t.boolean "matched_ndc_bin_pcn_state"
    t.boolean "matched_ndc_bin_pcn"
    t.boolean "matched_ndc_bin"
    t.integer "days_supply"
    t.string "transaction_code"
    t.string "card_holder"
    t.string "primary_bin"
    t.string "primary_pcn"
    t.string "primary_group"
    t.string "primary_payer_name"
    t.string "primary_plan_name"
    t.string "primary_plan_type"
    t.string "primary_benefit_plan_name"
  end

  create_table "rx_details", id: :serial, force: :cascade do |t|
    t.string "rx_number", limit: 255, null: false
    t.integer "member_id", null: false
    t.string "status", limit: 255, null: false
    t.decimal "amount_saved", precision: 10, scale: 2, null: false
    t.string "notes", limit: 255
    t.timestamptz "createdAt", null: false
    t.timestamptz "updatedAt", null: false
  end

  create_table "standard_reference_prices", force: :cascade do |t|
    t.string "ndc"
    t.float "awp"
    t.string "package_size"
    t.float "awp_per_package_size"
    t.float "reimbursement_per_quantity_dispensed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "matched_status", default: false
    t.string "health_system_name"
  end

  create_table "transactions", id: :serial, force: :cascade do |t|
    t.string "adj_date_time", limit: 255
    t.string "rx_number", limit: 255, null: false
    t.string "date_filled", limit: 255
    t.string "prescription_date_written", limit: 255, null: false
    t.string "claim_id", limit: 255, null: false
    t.string "reversed_claim_id", limit: 255, null: false
    t.string "transaction_status", limit: 255, null: false
    t.string "reject_code", limit: 255, null: false
    t.string "reject_message", limit: 255, null: false
    t.string "additional_message", limit: 255, null: false
    t.string "gpi", limit: 255, null: false
    t.string "drug_name", limit: 255
    t.string "quantity_dispensed", limit: 255
    t.string "days_supply", limit: 255, null: false
    t.string "fill_number", limit: 255, null: false
    t.string "number_of_refills_authorized", limit: 255, null: false
    t.string "prior_auth_number", limit: 255, null: false
    t.string "formulary_tier", limit: 255, null: false
    t.string "prescriber_dea", limit: 255, null: false
    t.string "prescriber_npi", limit: 255
    t.string "prescriber_first_name", limit: 255
    t.string "prescriber_last_name", limit: 255
    t.string "prescriber_address", limit: 255, null: false
    t.string "prescriber_city", limit: 255, null: false
    t.string "prescriber_state", limit: 255, null: false
    t.string "prescriber_zip", limit: 255, null: false
    t.string "prescriber_phone", limit: 255
    t.string "prescriber_fax", limit: 255, null: false
    t.string "pharmacy_ncpdp_id", limit: 255, null: false
    t.string "pharmacy_npi", limit: 255, null: false
    t.string "pharmacy_name", limit: 255
    t.string "pharmacy_address", limit: 255, null: false
    t.string "pharmacy_city", limit: 255, null: false
    t.string "pharmacy_state", limit: 255, null: false
    t.string "pharmacy_zip", limit: 255, null: false
    t.string "pharmacy_phone", limit: 255, null: false
    t.string "pharmacy_fax", limit: 255, null: false
    t.string "pharmacy_relationship_name", limit: 255, null: false
    t.string "manufacturer_name", limit: 255, null: false
    t.string "drug_dea_code", limit: 255, null: false
    t.string "drug_strength", limit: 255
    t.string "drug_form", limit: 255, null: false
    t.string "unit_of_measure", limit: 255, null: false
    t.string "route_of_admin", limit: 255, null: false
    t.string "rx_otc_indicator", limit: 255, null: false
    t.string "maintenance_flag", limit: 255
    t.string "mony", limit: 255
    t.string "ndc_11_digit", limit: 255, null: false
    t.integer "client_total_cost", default: 0, null: false
    t.float "awp_unit_cost", null: false
    t.float "awp_total", null: false
    t.float "mac_unit_cost", null: false
    t.float "mac_total", null: false
    t.string "pharmacy_ingredient_cost", limit: 255, null: false
    t.string "pharmacy_dispensing_fee", limit: 255, null: false
    t.float "pharmacy_sales_tax", null: false
    t.float "pharmacy_admin_fee", null: false
    t.float "total_due_to_pharmacy", null: false
    t.string "client_plan_paid", limit: 255, null: false
    t.string "total_patient_paid", limit: 255, null: false
    t.string "copay_assistance_program", limit: 255, null: false
    t.string "copay_assistance_amount", limit: 255, null: false
    t.integer "member_id", null: false
    t.integer "org_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "transactions_data", id: :serial, force: :cascade do |t|
    t.string "rx_number", limit: 255, null: false
    t.string "ndc_11_digit", limit: 255, null: false
    t.string "fill_number", limit: 255, null: false, array: true
    t.integer "client_total_cost"
    t.integer "average_client_total_cost"
    t.string "status", limit: 255, default: "enrolled", null: false
    t.string "eligibility_status", limit: 255, default: "inactive"
    t.string "status_340b", limit: 255, default: "inactive"
    t.boolean "admin_override", default: false
    t.integer "member_id", null: false
    t.integer "org_id", null: false
    t.integer "locations", array: true
    t.integer "rx_details"
    t.integer "transaction_meta_data", array: true
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "transactions_data_locations", id: :serial, force: :cascade do |t|
    t.integer "transactions_data_id", null: false
    t.float "longitude"
    t.float "latitude"
    t.string "location_type", limit: 255
    t.timestamptz "createdAt", null: false
    t.timestamptz "updatedAt", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "role", limit: 255, null: false
    t.string "email", limit: 255, null: false
    t.string "full_name", limit: 255, null: false
    t.string "password", limit: 255, null: false
    t.string "password_reset_token", limit: 255
    t.timestamptz "password_reset_expiry_time"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.string "image_url", limit: 255
  end

  add_foreign_key "org_assigns", "organizations", column: "org_id", name: "org_assigns_org_id_fkey"
  add_foreign_key "org_assigns", "users", name: "org_assigns_user_id_fkey"
end
