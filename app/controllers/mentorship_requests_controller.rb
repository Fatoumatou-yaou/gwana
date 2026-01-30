class MentorshipRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mentorship_request, only: [:show, :accept, :reject]
  after_action :verify_authorized, except: [:index]

  def index
    if current_user.user?
      @mentorship_requests = policy_scope(MentorshipRequest).for_requester(current_user.id).order(created_at: :desc)
    elsif current_user.gwana?
      @mentorship_requests = policy_scope(MentorshipRequest).for_mentor(current_user.id).order(created_at: :desc)
    else
      @mentorship_requests = policy_scope(MentorshipRequest).order(created_at: :desc)
    end
  end

  def show
    authorize @mentorship_request
  end

  def new
    @mentorship_request = MentorshipRequest.new
    # Pré-sélectionner le mentor si mentor_id est passé en paramètre
    if params[:mentor_id].present?
      mentor_user = User.find_by(id: params[:mentor_id])
      if mentor_user&.gwana? && mentor_user.gwana_profile&.available_for_mentorship?
        @mentorship_request.mentor_id = params[:mentor_id]
      end
    end
    @gwanas = User.gwana.joins(:gwana_profile).where(gwanas: { available_for_mentorship: true }).includes(:gwana_profile).order("gwanas.first_name, gwanas.last_name")
    @regions = Region.ordered
    authorize @mentorship_request
  end

  def create
    @mentorship_request = MentorshipRequest.new(mentorship_request_params)
    @mentorship_request.requester = current_user
    
    # Gérer la commune depuis les paramètres région/département/commune
    if params[:mentorship_request][:commune_id].present?
      @mentorship_request.commune_id = params[:mentorship_request][:commune_id]
    end
    
    authorize @mentorship_request

    if @mentorship_request.save
      redirect_to dashboard_path, notice: "Votre demande de mentorat a été envoyée avec succès."
    else
      @gwanas = User.gwana.joins(:gwana_profile).where(gwanas: { available_for_mentorship: true }).includes(:gwana_profile).order("gwanas.first_name, gwanas.last_name")
      @regions = Region.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def accept
    authorize @mentorship_request, :accept?
    if @mentorship_request.accept!
      redirect_to dashboard_path, notice: "La demande de mentorat a été acceptée."
    else
      redirect_to mentorship_request_path(@mentorship_request), alert: "Une erreur est survenue."
    end
  end

  def reject
    authorize @mentorship_request, :reject?
    if @mentorship_request.reject!
      redirect_to dashboard_path, notice: "La demande de mentorat a été refusée."
    else
      redirect_to mentorship_request_path(@mentorship_request), alert: "Une erreur est survenue."
    end
  end

  private

  def set_mentorship_request
    @mentorship_request = MentorshipRequest.find(params[:id])
  end

  def mentorship_request_params
    params.require(:mentorship_request).permit(:mentor_id, :motivation, :commune_id, :niveau_etudes, :filiere)
  end
end
