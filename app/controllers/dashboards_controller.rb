
class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user.decorate
    
    if @user.user?
      # Demandes de mentorat pour les utilisateurs
      @my_mentorship_requests = @user.mentorship_requests_as_requester.order(created_at: :desc)
    elsif @user.gwana?
      @metrics = GwanaDashboardMetricsService.new(current_user).call
      @gwana = @user.gwana_profile || @user.build_gwana_profile
      @gwana = @gwana.decorate if @gwana.persisted?
    end
  end
end

