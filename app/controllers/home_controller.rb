# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @members_count = Member.count
    @mentors_count = User.mentors.count
    @requests_count = MentorshipRequest.pending.count
    @recent_articles = Article.published.recent.limit(3)
    @featured_members = Member.available_for_mentorship.limit(6)
  end
end
