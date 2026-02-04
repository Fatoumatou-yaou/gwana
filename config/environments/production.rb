require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files (see config/storage.yml for options).
  # Options: :local, :digitalocean (Spaces), :hetzner (Object Storage)
  # Set ACTIVE_STORAGE_SERVICE environment variable to choose the service
  config.active_storage.service = ENV.fetch("ACTIVE_STORAGE_SERVICE", "local").to_sym

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :sidekiq

  # Configuration Mailgun pour l'envoi d'emails
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { 
    host: ENV.fetch("APP_DOMAIN", "gwanas.org"),
    protocol: "https"
  }

  # Configuration Mailgun depuis les credentials Rails
  mailgun_creds = Rails.application.credentials.dig(:mailgun)
  if mailgun_creds
    # Utiliser l'API Mailgun si disponible (plus fiable que SMTP)
    if mailgun_creds[:api_key].present?
      # L'initializer mailgun_api_delivery.rb configurera automatiquement :mailgun_api
      config.action_mailer.delivery_method = :mailgun_api
      config.after_initialize do
        Rails.logger.info "Mailgun API delivery activé" if Rails.logger
      end
    else
      # Fallback vers SMTP si pas d'API key
      config.action_mailer.delivery_method = :smtp
      config.action_mailer.smtp_settings = {
        address: mailgun_creds[:smtp_server] || "smtp.mailgun.org",
        port: (mailgun_creds[:smtp_port] || 587).to_i,
        domain: mailgun_creds[:domain] || "gwanas.org",
        user_name: mailgun_creds[:smtp_login],
        password: mailgun_creds[:smtp_password],
        authentication: (mailgun_creds[:authentication] || "plain").to_sym,
        enable_starttls_auto: mailgun_creds[:enable_starttls_auto] != false,
        open_timeout: 30,
        read_timeout: 30
      }
      config.after_initialize do
        Rails.logger.info "Mailgun SMTP delivery activé" if Rails.logger
      end
    end

    # Configurer l'expéditeur par défaut
    defaut_creds = Rails.application.credentials.dig(:defaut)
    if defaut_creds
      ActionMailer::Base.default from: defaut_creds[:email_from] || "no-reply@gwanas.org"
      ActionMailer::Base.default reply_to: defaut_creds[:email_reply_to] if defaut_creds[:email_reply_to]
    end
  else
    # Fallback : bloquer les emails si Mailgun n'est pas configuré
    config.action_mailer.delivery_method = :test
    config.action_mailer.perform_deliveries = false
    config.after_initialize do
      Rails.logger.warn "Mailgun credentials not found, emails are disabled" if Rails.logger
    end
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
