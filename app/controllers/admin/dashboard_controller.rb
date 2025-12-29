class Admin::DashboardController < Admin::BaseController
  def show
    # Statistiques générales
    @gwanas_count = Gwana.count
    @users_count = User.user.count
    @admins_count = User.admin.count
    @total_users = User.count
    
    # Statistiques mentorat
    @requests_count = MentorshipRequest.count
    @pending_requests = MentorshipRequest.pending.count
    @accepted_requests = MentorshipRequest.accepted.count
    @rejected_requests = MentorshipRequest.rejected.count
    @completed_requests = MentorshipRequest.completed.count
    
    # Statistiques articles
    @articles_count = Article.count
    @published_articles = Article.published.count
    @draft_articles = Article.count - @published_articles
    
    # Demandes de mise à jour
    @pending_update_requests_count = GwanaUpdateRequest.pending.count
    
    # Données pour graphiques
    @requests_by_region = MentorshipRequest.joins(requester: :gwana_profile)
                                          .where.not(gwanas: { region: nil })
                                          .group("gwanas.region")
                                          .count
    
    # Données temporelles (toute l'année en cours)
    current_year = Time.current.year
    year_start = Time.zone.local(current_year, 1, 1).beginning_of_month
    year_end = Time.zone.local(current_year, 12, 31).end_of_month
    
    # Créer un hash avec tous les mois de l'année initialisés à 0
    months_data = {}
    12.times do |i|
      month_start = year_start + i.months
      months_data[month_start] = 0
    end
    
    # Récupérer les données réelles de l'année en cours
    users_data = User.where(created_at: year_start..year_end)
                     .group(Arel.sql("DATE_TRUNC('month', created_at)"))
                     .count
    
    # Fusionner les données réelles avec les dates initialisées
    users_data.each do |date_key, count|
      # Convertir la clé en début de mois (Time)
      month_start = if date_key.is_a?(Time) || date_key.is_a?(DateTime)
                      date_key.beginning_of_month
                    elsif date_key.is_a?(Date)
                      date_key.beginning_of_month.to_time
                    else
                      begin
                        Date.parse(date_key.to_s).beginning_of_month.to_time
                      rescue
                        nil
                      end
                    end
      
      if month_start && months_data.key?(month_start)
        months_data[month_start] = count
      end
    end
    
    # Trier par date pour Chartkick (il accepte les Time comme clés)
    @users_by_month = months_data.sort.to_h
    
    # Données récentes
    @recent_requests = MentorshipRequest.recent.includes(requester: :gwana_profile, mentor: :gwana_profile).limit(5)
    @recent_gwanas = decorate(Gwana.order(created_at: :desc).limit(5))
    @recent_users = decorate(User.order(created_at: :desc).limit(5))
  end
end
