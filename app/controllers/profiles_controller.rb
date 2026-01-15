
class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_gwana, only: %i[show edit update]

  def show
    @gwana = current_user.gwana_profile || build_gwana
    @gwana = @gwana.decorate if @gwana.persisted?
  end

  def edit
    @gwana = current_user.gwana_profile || build_gwana
    @regions = Region.ordered
    # Charger les départements et communes si une commune est déjà sélectionnée
    commune = @gwana.commune
    if commune.present?
      @departments = commune.department.region.departments.ordered
      @communes = commune.department.communes.ordered
    else
      @departments = []
      @communes = []
    end
  end

  def update
    @gwana = current_user.gwana_profile || current_user.build_gwana_profile

    # Séparer les champs qui nécessitent validation (bio, photo) des autres
    bio = gwana_params[:bio]
    photo = gwana_params[:photo]
    commune_id = gwana_params[:commune_id]
    other_params = gwana_params.except(:bio, :photo, :commune_id, :region_id, :department_id)

    # Mettre à jour commune_id si fourni
    if commune_id.present?
      other_params[:commune_id] = commune_id
    end

    # Mettre à jour les champs qui ne nécessitent pas de validation
    update_success = other_params.empty? || @gwana.update(other_params)

    # Si bio ou photo sont modifiés, créer une demande de validation
    bio_changed = bio.present? && bio != @gwana.bio
    photo_changed = photo.present?

    if bio_changed || photo_changed
      request = GwanaUpdateRequestService.create(
        gwana: @gwana,
        bio: bio,
        photo: photo
      )

      if request && update_success
        redirect_to profile_path, notice: "Votre demande de mise à jour a été soumise et est en attente de validation par un administrateur."
      elsif !request
        @gwana.errors.add(:base, "Une erreur est survenue lors de la création de la demande de mise à jour.")
        prepare_edit_data
        render :edit, status: :unprocessable_entity
      else
        prepare_edit_data
        render :edit, status: :unprocessable_entity
      end
    elsif update_success
      redirect_to profile_path, notice: "Profil mis à jour avec succès"
    else
      prepare_edit_data
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_gwana
    @gwana = current_user.gwana_profile
  end

  def build_gwana
    current_user.build_gwana_profile
  end

  def gwana_params
    params.require(:gwana).permit(
      :first_name, :last_name, :bio, :profession, :skills,
      :phone, :address, :experiences, :formations,
      :available_for_mentorship, :linkedin_url,
      :twitter_url, :website_url, :photo, :commune_id
    )
  end

  def prepare_edit_data
    @regions = Region.ordered
    commune = @gwana.commune
    if commune.present?
      @departments = commune.department.region.departments.ordered
      @communes = commune.department.communes.ordered
    else
      @departments = []
      @communes = []
    end
  end
end
