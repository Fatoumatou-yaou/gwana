
class Admin::GwanasController < Admin::BaseController
    before_action :set_gwana, only: %i[show edit update destroy]

    def index
      gwanas = policy_scope(Gwana).includes(:user).order(created_at: :desc)
      @pagy, gwanas = pagy(gwanas)
      @gwanas = decorate(gwanas)
    end

    def show
      authorize [:admin, @gwana]
      @gwana = @gwana.decorate
    end

    def new
      @gwana = Gwana.new
      @gwana.build_user
      @regions = Region.ordered
      authorize [:admin, @gwana]
    end

    def create
      # Créer un objet temporaire pour l'autorisation
      # Le service créera le vrai objet avec tous les attributs
      @gwana = Gwana.new
      @gwana.build_user(email: gwana_params[:email])
      authorize [:admin, @gwana]

      # Préparer les paramètres pour le service
      # Convertir en hash simple et extraire l'email si présent dans user
      service_params = gwana_params.to_unsafe_h.symbolize_keys
      
      # Extraire l'email de user si présent
      if service_params[:user].present? && service_params[:user][:email].present?
        service_params[:email] = service_params[:user][:email]
      end
      
      # Nettoyer les paramètres non utilisés
      service_params.delete(:user)
      service_params.delete(:region_id)
      service_params.delete(:department_id)
      
      # Log pour debug (à retirer en production)
      Rails.logger.debug("Service params: #{service_params.inspect}")
      
      result = GwanaCreationService.call(service_params)

      if result[:success]
        redirect_to admin_gwana_path(result[:gwana]), notice: "Nouvelle gwana créée avec succès!"
      else
        if result[:errors].is_a?(ActiveModel::Errors)
          result[:errors].each do |attribute, messages|
            Array(messages).each do |message|
              @gwana.errors.add(attribute, message)
            end
          end
        else
          result[:errors].each do |key, messages|
            Array(messages).each do |message|
              @gwana.errors.add(key, message)
            end
          end
        end
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize [:admin, @gwana]
      @regions = Region.ordered
      @departments = @gwana.commune&.department&.region&.departments&.ordered || []
      @communes = @gwana.commune&.department&.communes&.ordered || []
    end

    def update
      authorize [:admin, @gwana]

      update_params = gwana_params.except(:email, :photo, :user, :region_id, :department_id)
      
      if @gwana.update(update_params)
        @gwana.photo.attach(gwana_params[:photo]) if gwana_params[:photo].present?
        
        # Mettre à jour l'email de l'utilisateur si fourni
        if gwana_params[:email].present? && @gwana.user.email != gwana_params[:email]
          @gwana.user.update(email: gwana_params[:email])
        end
        
        redirect_to admin_gwana_path(@gwana), notice: "Compte gwana mis à jour avec succès"
      else
        @regions = Region.ordered
        @departments = @gwana.commune&.department&.region&.departments&.ordered || []
        @communes = @gwana.commune&.department&.communes&.ordered || []
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize [:admin, @gwana]
      @gwana.user.destroy
      redirect_to admin_gwanas_path, notice: "Compte gwana supprimé avec succès"
    end

    private

    def set_gwana
      @gwana = Gwana.friendly.find(params[:id])
    end

    def gwana_params
      permitted = params.require(:gwana).permit(
        :first_name, :last_name, :bio, :address, :phone, :photo, :commune_id, :region_id, :department_id, 
        :profession, :skills, :available_for_mentorship, :linkedin_url, :twitter_url, :website_url, :email,
        :experiences, :formations,
        user: [:email]
      )
      
      # Extraire l'email de user si présent (format user: { email: ... })
      if permitted[:user].present? && permitted[:user][:email].present?
        permitted[:email] = permitted[:user][:email]
        permitted.delete(:user)
      end
      
      permitted
    end
  end

