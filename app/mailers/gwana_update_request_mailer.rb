class GwanaUpdateRequestMailer < ApplicationMailer
  def new_request(gwana_update_request, admin)
    @gwana_update_request = gwana_update_request
    @gwana = gwana_update_request.gwana
    @admin = admin

    mail(
      to: @admin.email,
      subject: "Nouvelle demande de mise à jour de profil - #{@gwana.full_name}"
    )
  end

  def request_approved(gwana_update_request)
    @gwana_update_request = gwana_update_request
    @gwana = gwana_update_request.gwana

    mail(
      to: @gwana.user.email,
      subject: "Votre demande de mise à jour de profil a été approuvée"
    )
  end

  def request_rejected(gwana_update_request)
    @gwana_update_request = gwana_update_request
    @gwana = gwana_update_request.gwana

    mail(
      to: @gwana.user.email,
      subject: "Votre demande de mise à jour de profil a été refusée"
    )
  end
end

