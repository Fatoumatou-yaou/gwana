# frozen_string_literal: true

class MentorshipRequestMailer < ApplicationMailer
  def new_request(mentorship_request)
    @mentorship_request = mentorship_request
    @mentor = mentorship_request.mentor
    @requester = mentorship_request.requester

    mail(
      to: @mentor.email,
      subject: t("mentorship_request_mailer.new_request.subject", requester_name: @requester.member_profile&.full_name || @requester.email)
    )
  end

  def request_accepted(mentorship_request)
    @mentorship_request = mentorship_request
    @mentor = mentorship_request.mentor
    @requester = mentorship_request.requester

    mail(
      to: @requester.email,
      subject: t("mentorship_request_mailer.request_accepted.subject")
    )
  end

  def request_rejected(mentorship_request)
    @mentorship_request = mentorship_request
    @mentor = mentorship_request.mentor
    @requester = mentorship_request.requester

    mail(
      to: @requester.email,
      subject: t("mentorship_request_mailer.request_rejected.subject")
    )
  end
end
