class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.dig(:default, :email_from) || "no-reply@gwanas.org"
  layout 'mailer'
  
  def default_url_options
    Rails.application.config.action_mailer.default_url_options
  end
end