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
    @draft_articles = @articles_count - @published_articles

    @articles_distribution = {
      "Publiés" => @published_articles,
      "Brouillons" => @draft_articles
    }

    # Demandes de mise à jour
    @pending_update_requests_count = GwanaUpdateRequest.pending.count

    # Données pour graphiques
    @requests_by_region = MentorshipRequest.joins(requester: :gwana_profile)
                                          .where.not(gwanas: { region: nil })
                                          .group("gwanas.region")
                                          .count

    @mentorship_status_distribution = MentorshipRequest.group(:status).count.transform_keys do |status|
      case status.to_s
      when 'pending' then 'En attente'
      when 'accepted' then 'Acceptées'
      when 'rejected' then 'Refusées'
      when 'completed' then 'Terminées'
      else status.to_s.capitalize
      end
    end

    # Évolution des utilisateurs (12 derniers mois)
    @users_by_month = User.group_by_month(:created_at, last: 12, current: true).count

    # Données récentes
    @recent_requests = MentorshipRequest.recent.includes(requester: :gwana_profile, mentor: :gwana_profile).limit(5)
    @recent_gwanas = decorate(Gwana.order(created_at: :desc).limit(5))
    @recent_users = decorate(User.order(created_at: :desc).limit(5))

    # Statistiques de visiteurs
    @visitors_today = PageView.today.select(:ip_address).distinct.count
    @visitors_this_week = PageView.this_week.select(:ip_address).distinct.count
    @visitors_this_month = PageView.this_month.select(:ip_address).distinct.count
    @total_visitors = PageView.count

    @page_views_by_day = PageView.group_by_day(:created_at, last: 30, current: true).count
    @top_pages = PageView.group(:path).order(count_all: :desc).limit(5).count
  end
end
