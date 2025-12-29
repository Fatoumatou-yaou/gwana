
class GwanaUpdateRequestService
  def self.create(gwana:, bio: nil, photo: nil)
    new(gwana: gwana, bio: bio, photo: photo).create
  end

  def self.approve(request:, reviewer:)
    new(request: request, reviewer: reviewer).approve
  end

  def self.reject(request:, reviewer:)
    new(request: request, reviewer: reviewer).reject
  end

  def initialize(gwana: nil, bio: nil, photo: nil, request: nil, reviewer: nil)
    @gwana = gwana
    @bio = bio
    @photo = photo
    @request = request
    @reviewer = reviewer
  end

  def create
    return false unless @gwana

    # Vérifier s'il y a vraiment des changements
    bio_changed = @bio.present? && @bio != @gwana.bio
    photo_changed = @photo.present?

    return false unless bio_changed || photo_changed

    request = @gwana.gwana_update_requests.create!(
      bio: @bio,
      status: :pending
    )

    # Attacher la photo si présente
    if @photo.present?
      request.photo.attach(@photo)
    end

    # Envoyer la notification aux admins
    notify_admins(request)

    request
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to create gwana update request: #{e.message}")
    false
  end

  def approve
    return false unless @request&.pending?

    ActiveRecord::Base.transaction do
      gwana = @request.gwana
      updates = {}

      # Appliquer les modifications au gwana
      if @request.has_bio_update?
        updates[:bio] = @request.bio
      end

      gwana.update!(updates) if updates.any?

      if @request.has_photo_update?
        gwana.photo.purge if gwana.photo.attached?
        gwana.photo.attach(@request.photo.blob)
      end

      # Marquer la demande comme approuvée
      @request.approve!(reviewer: @reviewer)
    end

    true
  rescue StandardError => e
    Rails.logger.error("Failed to approve gwana update request: #{e.message}")
    false
  end

  def reject
    return false unless @request&.pending?

    @request.reject!(reviewer: @reviewer)
    true
  rescue StandardError => e
    Rails.logger.error("Failed to reject gwana update request: #{e.message}")
    false
  end

  private

  def notify_admins(request)
    admin_users = User.where(role: [:admin, :admin_reseau])
    admin_users.each do |admin|
      GwanaUpdateRequestMailer.new_request(request, admin).deliver_later
    end
  end
end

