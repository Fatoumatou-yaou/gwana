
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
      @departments = []
      @communes = []
      authorize [:admin, @gwana]
    end

    def create
      # Préparer les paramètres pour le service
      service_params = gwana_params.to_unsafe_h.symbolize_keys
      
      # Extraire l'email de user si présent
      email = service_params[:email] || (service_params[:user].present? ? service_params[:user][:email] : nil)
      
      # Créer un objet temporaire pour l'autorisation et pré-remplir avec les valeurs du formulaire
      @gwana = Gwana.new(
        first_name: service_params[:first_name],
        last_name: service_params[:last_name],
        bio: service_params[:bio],
        address: service_params[:address],
        phone: service_params[:phone],
        profession: service_params[:profession],
        experiences: service_params[:experiences],
        formations: service_params[:formations],
        linkedin_url: service_params[:linkedin_url],
        twitter_url: service_params[:twitter_url],
        website_url: service_params[:website_url],
        commune_id: service_params[:commune_id]
      )
      @gwana.build_user(email: email)
      authorize [:admin, @gwana]

      # Nettoyer les paramètres non utilisés pour le service
      service_params_for_service = service_params.dup
      service_params_for_service.delete(:user)
      service_params_for_service.delete(:region_id)
      service_params_for_service.delete(:department_id)
      service_params_for_service[:email] = email if email.present?
      
      result = GwanaCreationService.call(service_params_for_service)

      if result[:success]
        redirect_to admin_gwana_path(result[:gwana]), notice: "Nouvelle gwana créée avec succès!"
      else
        # Copier les erreurs du service vers @gwana
        if result[:errors].is_a?(ActiveModel::Errors)
          # Si c'est un objet ActiveModel::Errors, vérifier de quel modèle il provient
          error_record = result[:errors].instance_variable_get(:@base)
          
          # Utiliser messages pour obtenir un hash { attribute => [messages] }
          result[:errors].messages.each do |attribute, messages|
            Array(messages).each do |message|
              # Si l'erreur vient d'un User et concerne l'email
              if error_record.is_a?(User) && (attribute.to_s == "email" || attribute.to_sym == :email)
                @gwana.user.errors.add(:email, message) if @gwana.user.present?
                @gwana.errors.add(:email, message) # Aussi sur gwana pour l'affichage
              # Si l'erreur vient d'un Gwana
              elsif error_record.is_a?(Gwana)
                @gwana.errors.add(attribute, message)
              # Sinon, traiter comme une erreur de gwana
              else
                if attribute.to_s == "email" || attribute.to_sym == :email
                  @gwana.user.errors.add(:email, message) if @gwana.user.present?
                  @gwana.errors.add(:email, message)
                else
                  @gwana.errors.add(attribute, message)
                end
              end
            end
          end
        else
          # Si c'est un hash d'erreurs
          result[:errors].each do |key, messages|
            Array(messages).each do |message|
              # Si l'erreur est sur :email, l'ajouter à user
              if key.to_s == "email" || key.to_sym == :email
                @gwana.user.errors.add(:email, message) if @gwana.user.present?
                @gwana.errors.add(:email, message) # Aussi sur gwana pour l'affichage
              else
                @gwana.errors.add(key, message)
              end
            end
          end
        end
        
        # Debug: logger les erreurs pour vérification
        Rails.logger.debug("Errors on @gwana: #{@gwana.errors.full_messages.inspect}")
        Rails.logger.debug("Errors on @gwana.user: #{@gwana.user&.errors&.full_messages&.inspect}")
        
        # Initialiser les variables nécessaires pour le rendu
        @regions = Region.ordered
        region_id = service_params[:region_id] || gwana_params[:region_id]
        department_id = service_params[:department_id] || gwana_params[:department_id]
        
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

    def edit
      authorize [:admin, @gwana]
      @regions = Region.ordered
      # Accéder à l'objet original avant de décorer pour éviter le conflit avec la méthode commune du decorator
      commune = @gwana.commune
      if commune.present?
        @departments = commune.department.region.departments.ordered
        @communes = commune.department.communes.ordered
      else
        @departments = []
        @communes = []
      end
      @gwana = @gwana.decorate
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
        @gwana = @gwana.decorate
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

