class Admin::GwanaUpdateRequestsController < Admin::BaseController
    before_action :set_gwana_update_request, only: %i[show approve reject]

    def index
        @pending_requests = policy_scope(GwanaUpdateRequest).pending.includes(:gwana).recent
        @approved_requests = policy_scope(GwanaUpdateRequest).approved.includes(:gwana, :reviewed_by).recent.limit(20)
        @rejected_requests = policy_scope(GwanaUpdateRequest).rejected.includes(:gwana, :reviewed_by).recent.limit(20)
    end

    def show
        authorize [:admin, @gwana_update_request]
    end

    def approve
        authorize [:admin, @gwana_update_request]

        if GwanaUpdateRequestService.approve(request: @gwana_update_request, reviewer: current_user)
        GwanaUpdateRequestMailer.request_approved(@gwana_update_request).deliver_later
        redirect_to admin_gwana_update_requests_path, notice: "Demande de mise à jour approuvée avec succès"
      else
        redirect_to admin_gwana_update_request_path(@gwana_update_request), alert: "Une erreur est survenue lors de l'approbation de la demande"
        end
    end

    def reject
        authorize [:admin, @gwana_update_request]

        if GwanaUpdateRequestService.reject(request: @gwana_update_request, reviewer: current_user)
        GwanaUpdateRequestMailer.request_rejected(@gwana_update_request).deliver_later
        redirect_to admin_gwana_update_requests_path, notice: "Demande de mise à jour refusée"
      else
        redirect_to admin_gwana_update_request_path(@gwana_update_request), alert: "Une erreur est survenue lors du refus de la demande"
        end
    end

    private

    def set_gwana_update_request
        @gwana_update_request = GwanaUpdateRequest.find(params[:id])
    end
end

