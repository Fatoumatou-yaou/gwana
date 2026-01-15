
class GwanaCreationService
  def self.call(params)
    new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      # Extraire les paramètres (gérer les symboles et les strings)
      email = @params[:email] || @params["email"]
      first_name = @params[:first_name] || @params["first_name"]
      last_name = @params[:last_name] || @params["last_name"]
      
      # Log pour debug (à retirer en production)
      Rails.logger.debug("GwanaCreationService params: email=#{email}, first_name=#{first_name}, last_name=#{last_name}")
      
      unless email.present?
        return { success: false, errors: { email: ["doit être rempli(e)"] } }
      end
      
      unless first_name.present? && last_name.present?
        return { success: false, errors: { base: ["Le prénom et le nom sont requis"] } }
      end
      
      # Générer un mot de passe temporaire
      temporary_password = generate_temporary_password
      
      # Créer le User avec le mot de passe temporaire
      # Le compte n'est pas vérifié (is_verified: false par défaut)
      # L'utilisateur devra utiliser le mot de passe temporaire puis l'OTP pour vérifier son compte
      user = User.create!(
        email: email,
        first_name: first_name,
        last_name: last_name,
        password: temporary_password,
        password_confirmation: temporary_password,
        profile: :gwana,
        is_verified: false
      )

      # Créer le profil gwana
      gwana = user.build_gwana_profile(
        first_name: first_name,
        last_name: last_name,
        bio: @params[:bio] || @params["bio"],
        profession: @params[:profession] || @params["profession"],
        skills: @params[:skills] || @params["skills"],
        commune_id: @params[:commune_id] || @params["commune_id"],
        experiences: @params[:experiences] || @params["experiences"],
        formations: @params[:formations] || @params["formations"]
      )

      # Ajouter address et phone si présents
      gwana.address = (@params[:address] || @params["address"]) if (@params[:address] || @params["address"]).present?
      gwana.phone = (@params[:phone] || @params["phone"]) if (@params[:phone] || @params["phone"]).present?
      
      # Ajouter les URLs si présentes
      gwana.linkedin_url = (@params[:linkedin_url] || @params["linkedin_url"]) if (@params[:linkedin_url] || @params["linkedin_url"]).present?
      gwana.twitter_url = (@params[:twitter_url] || @params["twitter_url"]) if (@params[:twitter_url] || @params["twitter_url"]).present?
      gwana.website_url = (@params[:website_url] || @params["website_url"]) if (@params[:website_url] || @params["website_url"]).present?

      # Attacher la photo si présente
      photo = @params[:photo] || @params["photo"]
      if photo.present?
        gwana.photo.attach(photo)
      end

      gwana.save!

      # Envoyer le mot de passe temporaire par email
      # (bloqué en production via config.action_mailer.perform_deliveries = false)
      send_temporary_password(user, temporary_password)

      { success: true, user: user, gwana: gwana }
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to create gwana: #{e.message}")
    { success: false, errors: e.record.errors }
  rescue StandardError => e
    Rails.logger.error("Failed to create gwana: #{e.message}")
    { success: false, errors: { base: [e.message] } }
  end

  private

  def generate_temporary_password
    # Générer un mot de passe temporaire sécurisé
    SecureRandom.alphanumeric(8)
  end

  def send_temporary_password(user, password)
    # Envoyer le mot de passe temporaire par email
    UserMailer.send_credentials(user, password).deliver_now
  end
end

