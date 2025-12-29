
class MentorshipRequestMailer < ApplicationMailer
  def new_request(mentorship_request)
    @mentorship_request = mentorship_request
    @mentor = mentorship_request.mentor
    @requester = mentorship_request.requester

    mail(
      to: @mentor.email,
      subject: "Nouvelle demande de mentorat de #{@requester.full_name || @requester.email}"
    )
  end

  def request_accepted(mentorship_request)
    @mentorship_request = mentorship_request
    @mentor = mentorship_request.mentor
    @requester = mentorship_request.requester

    mail(
      to: @requester.email,
      subject: "Votre demande de mentorat a été acceptée"
    )
  end

  def request_rejected(mentorship_request)
    @mentorship_request = mentorship_request
    @mentor = mentorship_request.mentor
    @requester = mentorship_request.requester

    mail(
      to: @requester.email,
      subject: "Votre demande de mentorat a été refusée"
    )
  end
end
