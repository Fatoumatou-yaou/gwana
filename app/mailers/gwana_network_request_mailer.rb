class GwanaNetworkRequestMailer < ApplicationMailer
  def new_request(gwana_network_request, admin)
    @request = gwana_network_request
    @admin = admin

    mail(
      to: @admin.email,
      subject: "Nouvelle demande de rejoindre le réseau GWANA - #{@request.full_name}"
    )
  end

  def request_received(gwana_network_request)
    @request = gwana_network_request

    mail(
      to: @request.email,
      subject: "Votre demande de rejoindre le réseau GWANA a été reçue"
    )
  end

  def request_approved(gwana_network_request)
    @request = gwana_network_request

    mail(
      to: @request.email,
      subject: "Votre demande de rejoindre le réseau GWANA a été approuvée"
    )
  end

  def request_rejected(gwana_network_request)
    @request = gwana_network_request

    mail(
      to: @request.email,
      subject: "Votre demande de rejoindre le réseau GWANA a été refusée"
    )
  end
end

