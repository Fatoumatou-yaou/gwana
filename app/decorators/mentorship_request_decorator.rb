class MentorshipRequestDecorator < ApplicationDecorator
  delegate_all

  def status_label
    case object.status
    when 'pending'
      'En attente'
    when 'accepted'
      'Accepté'
    when 'rejected'
      'Refusé'
    when 'completed'
      'Terminé'
    when 'cancelled'
      'Annulé'
    else
      object.status.humanize
    end
  end

  def mentor_name
    if object.mentor.gwana_profile
      "#{object.mentor.gwana_profile.first_name} #{object.mentor.gwana_profile.last_name}"
    else
      object.mentor.decorate.full_name || object.mentor.email
    end
  end

  def requester_name
    object.requester.decorate.full_name || object.requester.email
  end

  def formatted_created_at
    return "" unless object.created_at
    I18n.l(object.created_at, format: :short)
  end

  def status_badge
    helpers.mentorship_request_status_badge(object)
  end
end

