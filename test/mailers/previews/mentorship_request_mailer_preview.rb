# Preview all emails at http://localhost:3000/rails/mailers/mentorship_request_mailer
class MentorshipRequestMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/mentorship_request_mailer/new_request
  def new_request
    MentorshipRequestMailer.new_request
  end

  # Preview this email at http://localhost:3000/rails/mailers/mentorship_request_mailer/request_accepted
  def request_accepted
    MentorshipRequestMailer.request_accepted
  end

  # Preview this email at http://localhost:3000/rails/mailers/mentorship_request_mailer/request_rejected
  def request_rejected
    MentorshipRequestMailer.request_rejected
  end
end
