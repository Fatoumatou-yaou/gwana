class Admin::MentorshipRequestsController < Admin::BaseController
  before_action :set_mentorship_request, only: [:show, :approve]

  def index
    @mentorship_requests = MentorshipRequest.includes(:requester, :mentor).order(created_at: :desc)
    @pagy, @mentorship_requests = pagy(@mentorship_requests)
  end

  def show
    authorize [:admin, @mentorship_request]
  end

  def approve
    authorize [:admin, @mentorship_request]
    begin
      @mentorship_request.approve!
      redirect_to admin_mentorship_requests_path, notice: "La demande de mentorat a été approuvée."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_mentorship_request_path(@mentorship_request), alert: "Une erreur est survenue : #{e.message}"
    end
  end

  private

  def set_mentorship_request
    @mentorship_request = MentorshipRequest.find(params[:id])
  end
end

