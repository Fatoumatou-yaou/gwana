class GwanaActivitiesController < ApplicationController
  layout "slim"
  before_action :set_activity, only: [:show]

  def index
    @activities = policy_scope(GwanaActivity).includes(:gwana).recent
    @pagy, @activities = pagy(@activities)
    @activities = decorate(@activities)
  end

  def show
    authorize @activity
    @activity = @activity.decorate
  end

  private

  def set_activity
    @activity = GwanaActivity.find(params[:id])
  end
end

