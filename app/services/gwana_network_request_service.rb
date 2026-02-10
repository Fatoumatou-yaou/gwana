class GwanaNetworkRequestService
  attr_reader :errors

  def self.approve(request:, reviewer:)
    new(request: request, reviewer: reviewer).approve
  end

  def initialize(request:, reviewer:)
    @request = request
    @reviewer = reviewer
    @errors = []
  end

  def approve
    return false unless @request&.pending?

    # Vérifier d'abord si l'email est déjà utilisé
    if User.exists?(email: @request.email)
      @errors << "L'email #{@request.email} est déjà utilisé par un utilisateur existant"
      return false
    end

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
        
        # Extraire les messages d'erreur du résultat
        if result[:errors].is_a?(ActiveModel::Errors)
          result[:errors].full_messages.each do |message|
            @errors << message
          end
        elsif result[:errors].is_a?(Hash)
          result[:errors].each do |field, messages|
            if messages.is_a?(Array)
              messages.each { |msg| @errors << "#{field.to_s.humanize}: #{msg}" }
            else
              @errors << "#{field.to_s.humanize}: #{messages}"
            end
          end
        else
          @errors << result[:errors].to_s
        end
        
        raise ActiveRecord::Rollback
      end

      # Copier la photo de la demande vers le gwana
      if @request.photo.attached?
        result[:gwana].photo.attach(@request.photo.blob)
      end

      # Marquer la demande comme approuvée
      @request.approve!(reviewer: @reviewer)
    end

    @errors.empty?
  rescue ActiveRecord::Rollback
    false
  rescue StandardError => e
    Rails.logger.error("Failed to approve gwana network request: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    @errors << "Une erreur est survenue: #{e.message}"
    false
  end
end

