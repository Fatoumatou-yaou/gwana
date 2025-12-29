
class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user.decorate
    @gwana_profile = @user.gwana_profile&.decorate
    @my_mentorship_requests = @user.mentorship_requests_as_requester.order(created_at: :desc).limit(5)
    @mentorship_requests_as_mentor = @user.mentorship_requests_as_mentor.order(created_at: :desc).limit(5)
    @my_articles = @user.admin? ? decorate(@user.articles.order(created_at: :desc).limit(5)) : []
  end
end

