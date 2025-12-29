class Admin::MentorshipRequestsController < Admin::BaseController
  before_action :set_mentorship_request, only: [:show]

  def index
    @mentorship_requests = MentorshipRequest.includes(:requester, :mentor).order(created_at: :desc)
    @pagy, @mentorship_requests = pagy(@mentorship_requests)
  end

  def show
    authorize [:admin, @mentorship_request]
  end

  private

  def set_mentorship_request
    @mentorship_request = MentorshipRequest.find(params[:id])
  end
end

