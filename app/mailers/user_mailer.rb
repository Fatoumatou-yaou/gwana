class UserMailer < ApplicationMailer
  def send_credentials(user, password)
    @user = user
    @password = password

    mail(
      to: @user.email,
      subject: "Vos identifiants de connexion Gwana"
    )
  end
end

