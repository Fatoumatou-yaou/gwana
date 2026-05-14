class GwanaNetworkRequestsController < ApplicationController
  layout "slim"
  before_action :set_gwana_network_request, only: [ :show ]
  before_action :authorize_gwana_network_request, only: [ :new, :create ]

  def new
    @gwana_network_request = GwanaNetworkRequest.new
    @regions = Region.ordered
    @departments = []
    @communes = []
  end

  def create
    @gwana_network_request = GwanaNetworkRequest.new(gwana_network_request_params)
    @regions = Region.ordered

    if @gwana_network_request.save
      # Envoyer l'email de confirmation
      GwanaNetworkRequestMailer.request_received(@gwana_network_request).deliver_later

      # Notifier les admins
      notify_admins

      redirect_to root_path, notice: "Votre demande a été envoyée avec succès. Vous recevrez une réponse par email sous 1 mois."
    else
      # Préparer les données pour le formulaire en cas d'erreur
      region_id = params[:region_id] || gwana_network_request_params[:region_id]
      department_id = params[:department_id] || gwana_network_request_params[:department_id]

      if region_id.present?
        region = Region.find_by(id: region_id)
        @departments = region&.departments&.ordered || []
        if department_id.present?
          department = Department.find_by(id: department_id)
          @communes = department&.communes&.ordered || []
        else
          @communes = []
        end
      else
        @departments = []
        @communes = []
      end

      render :new, status: :unprocessable_entity
    end
  end

  def show
    # Permet de voir le statut de la demande (optionnel)
  end

  private

  def authorize_gwana_network_request
    authorize GwanaNetworkRequest
  end

  def set_gwana_network_request
    @gwana_network_request = GwanaNetworkRequest.find(params[:id])
    authorize @gwana_network_request
  end

  def gwana_network_request_params
    params.require(:gwana_network_request).permit(
      :first_name, :last_name, :email, :phone, :address, :commune_id,
      :profession, :experiences, :formations, :bio, :photo, :identity_document
    )
  end

  def notify_admins
    admin_users = User.where(profile: :admin)
    admin_users.each do |admin|
      GwanaNetworkRequestMailer.new_request(@gwana_network_request, admin).deliver_later
    end
  end
end
