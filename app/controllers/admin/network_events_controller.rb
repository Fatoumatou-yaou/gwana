class Admin::NetworkEventsController < Admin::BaseController
  before_action :set_network_event, only: [ :show, :edit, :update, :destroy ]

  def index
    network_events = policy_scope([ :admin, NetworkEvent ]).recent
    network_events = network_events.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    @pagy, network_events = pagy(network_events)
    @network_events = decorate(network_events)
  end

  def show
    authorize [ :admin, @network_event ]
    @network_event = @network_event.decorate
  end

  def new
    @network_event = NetworkEvent.new
    authorize [ :admin, @network_event ]
  end

  def create
    # Vérifier la taille des photos brutes AVANT tout filtrage (pour afficher l'erreur à l'utilisateur)
    raw_photos = params[:network_event][:photos] rescue nil
    if reject_if_photos_too_large!(raw_photos)
      @network_event = NetworkEvent.new(network_event_params)
      authorize [ :admin, @network_event ]
      render :new, status: :unprocessable_entity
      return
    end

    @network_event = NetworkEvent.new(network_event_params)
    authorize [ :admin, @network_event ]

    if @network_event.save
      Rails.logger.info("NetworkEvent créé avec succès, ID: #{@network_event.id}, Photos attachées: #{@network_event.photos.count}")
      flash[:notice] = "Événement créé avec succès."
      redirect_to admin_network_event_path(@network_event)
    else
      # Logger les erreurs pour le debugging en production
      Rails.logger.error("=== NetworkEvent creation failed ===")
      Rails.logger.error("Errors: #{@network_event.errors.full_messages.join('; ')}")
      Rails.logger.error("Params: name=#{network_event_params[:name]}, description length=#{network_event_params[:description]&.length}, event_date=#{network_event_params[:event_date]}")
      Rails.logger.error("Photos count in params: #{network_event_params[:photos]&.count || 0}")
      Rails.logger.error("Photos attached to object: #{@network_event.photos.count}")
      if network_event_params[:photos].present?
        network_event_params[:photos].each_with_index do |photo, index|
          if photo.respond_to?(:original_filename)
            Rails.logger.error("Photo #{index + 1}: filename=#{photo.original_filename}, size=#{photo.size} bytes, content_type=#{photo.content_type}")
          else
            Rails.logger.error("Photo #{index + 1}: type=#{photo.class}, value=#{photo.inspect}")
          end
        end
      end
      Rails.logger.error("=====================================")

      flash[:alert] = "Impossible de créer l'événement. Veuillez corriger les erreurs ci-dessous."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize [ :admin, @network_event ]
  end

  def update
    authorize [ :admin, @network_event ]

    # Vérifier la taille des photos brutes AVANT tout filtrage (pour afficher l'erreur à l'utilisateur)
    raw_photos = params[:network_event][:photos] rescue nil
    if reject_if_photos_too_large!(raw_photos)
      render :edit, status: :unprocessable_entity
      return
    end

    cleaned_params = network_event_params
    new_photos_count = cleaned_params[:photos]&.count || 0
    existing_photos_count = @network_event.photos.count
    total_photos_count = existing_photos_count + new_photos_count

    if cleaned_params[:photos].present? && total_photos_count > 30
      flash[:alert] = "Impossible d'ajouter ces photos. La limite est de 30 photos."
      render :edit, status: :unprocessable_entity
      return
    end

    if @network_event.update(cleaned_params)
      Rails.logger.info("NetworkEvent mis à jour avec succès, ID: #{@network_event.id}, Photos totales: #{@network_event.photos.count}")
      flash[:notice] = "Événement mis à jour avec succès."
      redirect_to admin_network_event_path(@network_event)
    else
      # Recharger l'objet depuis la DB pour éviter d'avoir des photos non persistées attachées
      # Cela évite l'erreur "Cannot get a signed_id for a new record" dans la vue
      @network_event.reload

      # Logger les erreurs pour le debugging en production
      Rails.logger.error("=== NetworkEvent update failed ===")
      Rails.logger.error("Event ID: #{@network_event.id}")
      Rails.logger.error("Errors: #{@network_event.errors.full_messages.join('; ')}")
      Rails.logger.error("Params: name=#{network_event_params[:name]}, description length=#{network_event_params[:description]&.length}, event_date=#{network_event_params[:event_date]}")
      Rails.logger.error("New photos count: #{new_photos_count}, Existing: #{existing_photos_count}, Total: #{total_photos_count}")
      if network_event_params[:photos].present?
        network_event_params[:photos].each_with_index do |photo, index|
          next if photo.blank?
          Rails.logger.error("Photo #{index + 1}: filename=#{photo.respond_to?(:original_filename) ? photo.original_filename : 'N/A'}, size=#{photo.respond_to?(:size) ? photo.size : 'N/A'} bytes")
        end
      end
      Rails.logger.error("===================================")

      flash[:alert] = "Impossible de mettre à jour l'événement. Veuillez corriger les erreurs ci-dessous."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize [ :admin, @network_event ]
    @network_event.destroy
    flash[:notice] = "Événement supprimé avec succès."
    redirect_to admin_network_events_path
  end

  private

  def set_network_event
    @network_event = NetworkEvent.find(params[:id])
  end

  # Vérifie les photos brutes (params) avant tout filtrage. Retourne true si au moins une photo
  # dépasse 4 Mo (et définit flash[:alert]). À appeler avant network_event_params.
  def reject_if_photos_too_large!(raw_photos)
    return false if raw_photos.blank?

    raw_photos.each do |photo|
      next unless photo.is_a?(ActionDispatch::Http::UploadedFile)
      if photo.size > 4.megabytes
        size_in_mb = (photo.size / 1.megabyte.to_f).round(2)
        filename = photo.original_filename
        flash[:alert] = "La photo \"#{filename}\" dépasse 4 Mo (taille actuelle : #{size_in_mb} Mo). Veuillez réduire la taille de l'image."
        return true
      end
    end
    false
  end

  def network_event_params
    permitted = params.require(:network_event).permit(:name, :description, :event_date, photos: [])

    # Logger les paramètres bruts pour le debugging
    raw_photos_param = params[:network_event][:photos] rescue nil
    Rails.logger.info("=== network_event_params ===")
    Rails.logger.info("Paramètres photos bruts: #{raw_photos_param.inspect}")
    Rails.logger.info("Type: #{raw_photos_param.class}")
    Rails.logger.info("Count: #{raw_photos_param&.count || 0}")

    # Filtrer les photos vides (chaînes vides) qui peuvent être envoyées par le formulaire
    # Ne garder que les fichiers uploadés valides (ActionDispatch::Http::UploadedFile)
    if permitted[:photos].present?
      # Logger chaque élément avant filtrage
      permitted[:photos].each_with_index do |photo, index|
        Rails.logger.info("Photo brute #{index + 1}: type=#{photo.class}, is_uploaded_file=#{photo.is_a?(ActionDispatch::Http::UploadedFile)}, blank?=#{photo.blank? rescue 'N/A'}")
      end

      # Filtrer : fichiers uploadés valides ET taille <= 4 Mo (ne jamais attacher de photo trop grosse)
      filtered_photos = permitted[:photos].reject(&:blank?).select do |photo|
        photo.is_a?(ActionDispatch::Http::UploadedFile) && photo.size <= 4.megabytes
      end

      # Si on a des photos valides, les utiliser
      # Si le tableau est vide après filtrage, ne pas inclure le paramètre photos
      # pour éviter de supprimer les photos existantes lors d'un update
      if filtered_photos.any?
        permitted[:photos] = filtered_photos
        Rails.logger.info("Photos filtrées: #{filtered_photos.count} fichier(s) valide(s)")
        filtered_photos.each_with_index do |photo, index|
          Rails.logger.info("Photo valide #{index + 1}: #{photo.original_filename}, #{photo.size} bytes, #{photo.content_type}")
        end
      else
        # Retirer le paramètre photos si aucun fichier valide
        # Cela permet de conserver les photos existantes lors d'un update
        permitted.delete(:photos)
        Rails.logger.info("Aucune photo valide, paramètre photos retiré pour préserver les photos existantes")
      end
    else
      Rails.logger.info("Aucun paramètre photos reçu dans permitted")
    end

    Rails.logger.info("Paramètres finaux: photos présent? #{permitted.key?(:photos)}, count: #{permitted[:photos]&.count || 0}")
    Rails.logger.info("============================")

    permitted
  end
end
