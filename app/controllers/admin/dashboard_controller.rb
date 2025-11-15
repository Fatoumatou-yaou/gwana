# frozen_string_literal: true

class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin

  def index
    @members_count = Member.count
    @users_count = User.count
    @mentors_count = User.mentors.count
    @requests_count = MentorshipRequest.count
    @pending_requests = MentorshipRequest.pending.count
    @articles_count = Article.count
    @published_articles = Article.published.count
    @recent_requests = MentorshipRequest.recent.limit(10)
    @recent_members = Member.order(created_at: :desc).limit(10)
  end

  private

  def authorize_admin
    redirect_to root_path, alert: t("pundit.not_authorized") unless current_user&.admin? || current_user&.admin_reseau?
  end
end
