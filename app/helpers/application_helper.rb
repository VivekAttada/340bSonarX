# frozen_string_literal: true

module ApplicationHelper
  def total_health_system_claims(details)
    RawFile.where(health_system_name: details).where(matched_status: true).where.not(paid_status: nil).sum(:program_revenue)
  end

  def total_revenue(details)
    RawFile.where(health_system_name: details).where(matched_status: true).sum(:program_revenue)
  end

  def contract_pharmacies_revenue(details)
    RawFile.where(health_system_name: params[:hospital_name], matched_status: true, rx_file_provider_name: details)
           .sum(:program_revenue)
  end

  def claim_count(details)
    calculate_revenue(details, not_paid_status: false)
  end

  def correctly_paid_claim(details)
    calculate_revenue(details, paid_status: 'correctly paid')
  end

  def over_paid_claim(details)
    calculate_revenue(details, paid_status: 'over paid')
  end

  def under_paid_claim(details)
    calculate_revenue(details, paid_status: 'under paid')
  end

  private

  def calculate_revenue(details, paid_status: nil, not_paid_status: true)
    query = RawFile.where(health_system_name: params[:hospital_name], rx_file_provider_name: details,
                          matched_status: true)
    query = query.where(paid_status: paid_status) if paid_status
    query = query.where.not(paid_status: nil) if not_paid_status
    query.sum(:program_revenue).to_i
  end
end
