# Adapter personnalisé pour utiliser l'API Mailgun
class MailgunApiDelivery
  def initialize(settings)
    @settings = settings
  end

  def deliver!(mail)
    mailgun_creds = Rails.application.credentials.dig(:mailgun)
    return false unless mailgun_creds

    api_key = mailgun_creds[:api_key]
    return false unless api_key.present?

    domain = mailgun_creds[:domain] || "gwanas.org"
    api_url = "https://api.mailgun.net/v3/#{domain}/messages"

    # Déterminer l'expéditeur
    defaut_creds = Rails.application.credentials.dig(:defaut)
    from_email = mail.from.first || defaut_creds&.dig(:email_from) || "no-reply@gwanas.org"

    # Préparer les données pour l'API
    data = {
      from: from_email,
      to: mail.to.join(","),
      subject: mail.subject
    }

    # Extraire le texte et HTML
    text_content = extract_text(mail)
    html_content = extract_html(mail)

    data[:text] = text_content if text_content.present?
    data[:html] = html_content if html_content.present?

    # Ajouter reply-to si présent
    if mail.reply_to.present?
      reply_to = mail.reply_to.first || defaut_creds&.dig(:email_reply_to)
      data[:"h:Reply-To"] = reply_to if reply_to
    end

    # Envoyer via l'API Mailgun
    response = send_to_mailgun_api(api_url, api_key, data)

    if response[:success]
      Rails.logger.info "Email envoyé via Mailgun API: #{response[:message_id]}"
      true
    else
      Rails.logger.error "Erreur envoi Mailgun API: #{response[:error]}"
      raise "Mailgun API Error: #{response[:error]}"
    end
  end

  private

  def extract_text(mail)
    if mail.text_part
      mail.text_part.body.to_s
    elsif mail.multipart?
      mail.parts.find { |p| p.content_type.include?("text/plain") }&.body&.to_s || ""
    else
      mail.body.to_s
    end
  end

  def extract_html(mail)
    if mail.html_part
      mail.html_part.body.to_s
    elsif mail.multipart?
      mail.parts.find { |p| p.content_type.include?("text/html") }&.body&.to_s || ""
    else
      nil
    end
  end

  def send_to_mailgun_api(url, api_key, data)
    require "net/http"
    require "uri"
    require "json"
    require "open3"
    require "tempfile"

    # Utiliser curl avec un fichier temporaire pour les données multipart
    # Plus fiable pour gérer les caractères spéciaux et les données complexes
    temp_file = Tempfile.new(["mailgun", ".txt"])
    
    begin
      # Construire le body multipart/form-data
      boundary = "----WebKitFormBoundary#{SecureRandom.hex(16)}"
      body_parts = []
      
      data.each do |key, value|
        next if value.nil? || value.to_s.empty?
        body_parts << "--#{boundary}"
        body_parts << "Content-Disposition: form-data; name=\"#{key}\""
        body_parts << ""
        body_parts << value.to_s
      end
      body_parts << "--#{boundary}--"
      
      body = body_parts.join("\r\n")
      temp_file.write(body)
      temp_file.rewind
      
      # Construire la commande curl
      cmd = [
        "curl", "-s",
        "--user", "api:#{api_key}",
        "-H", "Content-Type: multipart/form-data; boundary=#{boundary}",
        "--data-binary", "@#{temp_file.path}",
        url
      ]
      
      # Exécuter curl avec Open3
      stdout, stderr, status = Open3.capture3(*cmd)
      
      if status.success?
        begin
          response_data = JSON.parse(stdout)
          if response_data["id"]
            { success: true, message_id: response_data["id"] }
          else
            { success: false, error: response_data["message"] || "Unknown error" }
          end
        rescue JSON::ParserError => e
          Rails.logger.error "Mailgun API - Invalid JSON: #{stdout}" if Rails.logger
          { success: false, error: "Invalid JSON response: #{stdout[0..200]}" }
        end
      else
        error_msg = stderr.present? ? stderr : stdout
        Rails.logger.error "Mailgun API - curl failed: #{error_msg}" if Rails.logger
        { success: false, error: "curl failed (exit #{status.exitstatus}): #{error_msg[0..200]}" }
      end
    ensure
      temp_file.close
      temp_file.unlink
    end
  rescue => e
    Rails.logger.error "Mailgun API - Exception: #{e.message}\n#{e.backtrace.first(5).join("\n")}" if Rails.logger
    { success: false, error: "#{e.class}: #{e.message}" }
  end
end

# Configurer ActionMailer pour utiliser l'API Mailgun si l'API key est présente
# Fonctionne en développement et production
mailgun_creds = Rails.application.credentials.dig(:mailgun)
if mailgun_creds && mailgun_creds[:api_key].present?
  ActionMailer::Base.add_delivery_method :mailgun_api, MailgunApiDelivery
  
  # Activer automatiquement en production, optionnel en développement
  if Rails.env.production?
    Rails.application.config.action_mailer.delivery_method = :mailgun_api
    Rails.application.config.after_initialize do
      Rails.logger.info "Mailgun API delivery method activé (production)" if Rails.logger
    end
  end
end

