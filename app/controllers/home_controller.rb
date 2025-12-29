class HomeController < ApplicationController
  layout "slim"

  def index
    @gwanas_count = Gwana.count
    # @mentors_count = User.mentors.count
    @requests_count = MentorshipRequest.pending.count
    @recent_articles = decorate(Article.published.recent.limit(3))
    @featured_gwanas = decorate(Gwana.available_for_mentorship.limit(6))
    @directory_gwanas = decorate(Gwana.limit(14))
  end
end
