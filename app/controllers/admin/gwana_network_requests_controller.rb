class Admin::GwanaNetworkRequestsController < Admin::BaseController
  before_action :set_gwana_network_request, only: %i[show approve reject]

  def index
    authorize [:admin, GwanaNetworkRequest]
    requests = policy_scope([:admin, GwanaNetworkRequest]).includes(:commune, :reviewed_by).recent
    @pagy, requests = pagy(requests)
    @requests = decorate(requests)
  end

  def show
    authorize [:admin, @gwana_network_request]
  end

  def approve
    authorize [:admin, @gwana_network_request]

    if GwanaNetworkRequestService.approve(request: @gwana_network_request, reviewer: current_user)
      GwanaNetworkRequestMailer.request_approved(@gwana_network_request).deliver_later
      redirect_to admin_gwana_network_requests_path, notice: "Demande approuvée avec succès"
    else
      redirect_to admin_gwana_network_request_path(@gwana_network_request), alert: "Une erreur est survenue lors de l'approbation de la demande"
    end
  end

  def reject
    authorize [:admin, @gwana_network_request]

    rejection_reason = params[:rejection_reason]
    
    if rejection_reason.blank?
      redirect_to admin_gwana_network_request_path(@gwana_network_request), alert: "Le motif de rejet est obligatoire"
      return
    end

    if @gwana_network_request.reject!(reviewer: current_user, reason: rejection_reason)
      GwanaNetworkRequestMailer.request_rejected(@gwana_network_request).deliver_later
      redirect_to admin_gwana_network_requests_path, notice: "Demande refusée"
    else
      redirect_to admin_gwana_network_request_path(@gwana_network_request), alert: "Une erreur est survenue lors du refus de la demande"
    end
  end

  private

  def set_gwana_network_request
    @gwana_network_request = GwanaNetworkRequest.find(params[:id])
  end
end

