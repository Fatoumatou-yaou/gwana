class GwanaNetworkRequestService
  def self.approve(request:, reviewer:)
    new(request: request, reviewer: reviewer).approve
  end

  def initialize(request:, reviewer:)
    @request = request
    @reviewer = reviewer
  end

  def approve
    return false unless @request&.pending?

    ActiveRecord::Base.transaction do
      # Préparer les paramètres pour GwanaCreationService
      service_params = {
        email: @request.email,
        first_name: @request.first_name,
        last_name: @request.last_name,
        bio: @request.bio,
        profession: @request.profession,
        commune_id: @request.commune_id,
        experiences: @request.experiences,
        formations: @request.formations,
        address: @request.address,
        phone: @request.phone,
        linkedin_url: @request.linkedin_url,
        twitter_url: @request.twitter_url,
        website_url: @request.website_url
      }

      # Créer le User et le Gwana via le service existant
      result = GwanaCreationService.call(service_params)

      unless result[:success]
        Rails.logger.error("Failed to create gwana from network request: #{result[:errors]}")
        return false
      end

      # Copier la photo de la demande vers le gwana
      if @request.photo.attached?
        result[:gwana].photo.attach(@request.photo.blob)
      end

      # Marquer la demande comme approuvée
      @request.approve!(reviewer: @reviewer)
    end

    true
  rescue StandardError => e
    Rails.logger.error("Failed to approve gwana network request: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    false
  end
end

