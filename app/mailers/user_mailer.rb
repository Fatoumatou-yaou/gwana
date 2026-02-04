class UserMailer < ApplicationMailer
  def send_credentials(user, password)
    @user = user
    @password = password

    defaut_creds = Rails.application.credentials.dig(:defaut)
    from_email = defaut_creds&.dig(:email_from) || "no-reply@gwanas.org"

    mail(
      to: @user.email,
      from: from_email,
      subject: "Vos identifiants de connexion Gwana"
    )
  end
end

