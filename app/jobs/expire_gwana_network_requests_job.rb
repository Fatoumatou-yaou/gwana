class ExpireGwanaNetworkRequestsJob < ApplicationJob
  queue_as :default

  def perform
    expired_requests = GwanaNetworkRequest.pending.expired

    expired_requests.find_each do |request|
      request.update(
        status: :rejected,
        rejection_reason: "Demande expirée : aucune réponse n'a été donnée dans le délai d'un mois."
      )
    end

    Rails.logger.info("Expired #{expired_requests.count} gwana network requests")
  end
end

