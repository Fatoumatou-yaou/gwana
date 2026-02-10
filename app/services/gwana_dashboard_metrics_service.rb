class GwanaDashboardMetricsService
  def initialize(gwana_user)
    @gwana_user = gwana_user
  end

  def call
    {
      total_mentorships: total_mentorships,
      mentorships_by_status: mentorships_by_status,
      pending_mentorships: pending_mentorships,
      accepted_mentorships: accepted_mentorships,
      rejected_mentorships: rejected_mentorships,
      completed_mentorships: completed_mentorships,
      cancelled_mentorships: cancelled_mentorships,
      recent_mentorships: recent_mentorships,
      mentorships_by_month: mentorships_by_month,
      average_response_time: average_response_time
    }
  end

  private

  attr_reader :gwana_user

  def mentorship_requests
    @mentorship_requests ||= gwana_user.mentorship_requests_as_mentor
  end

  def total_mentorships
    mentorship_requests.count
  end

  def mentorships_by_status
    {
      pending: mentorship_requests.pending.count,
      accepted: mentorship_requests.accepted.count,
      rejected: mentorship_requests.rejected.count,
      completed: mentorship_requests.completed.count,
      cancelled: mentorship_requests.cancelled.count
    }
  end

  def pending_mentorships
    mentorship_requests.pending.count
  end

  def accepted_mentorships
    mentorship_requests.accepted.count
  end

  def rejected_mentorships
    mentorship_requests.rejected.count
  end

  def completed_mentorships
    mentorship_requests.completed.count
  end

  def cancelled_mentorships
    mentorship_requests.cancelled.count
  end

  def recent_mentorships
    mentorship_requests.recent.limit(5)
  end

  def mentorships_by_month
    current_year = Time.current.year
    year_start = Time.zone.local(current_year, 1, 1).beginning_of_month
    year_end = Time.zone.local(current_year, 12, 31).end_of_month

    # Créer un hash avec tous les mois de l'année initialisés à 0
    months_data = {}
    12.times do |i|
      month_start = year_start + i.months
      month_key = month_start.strftime("%Y-%m")
      months_data[month_key] = 0
    end

    # Récupérer les données réelles de l'année en cours
    actual_data = mentorship_requests
      .where(created_at: year_start..year_end)
      .group(Arel.sql("DATE_TRUNC('month', created_at)"))
      .count

    # Fusionner les données réelles avec les dates initialisées
    actual_data.each do |date_key, count|
      month_key = date_key.to_date.strftime("%Y-%m")
      months_data[month_key] = count if months_data.key?(month_key)
    end

    months_data
  end

  def average_response_time
    accepted_requests = mentorship_requests.accepted.where.not(updated_at: nil)
    return 0 if accepted_requests.empty?

    total_days = accepted_requests.sum do |request|
      (request.updated_at.to_date - request.created_at.to_date).to_i
    end

    (total_days.to_f / accepted_requests.count).round(1)
  end
end

