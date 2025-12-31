class GwanaNetworkRequestDecorator < ApplicationDecorator
  delegate_all

  def status
    case object.status
    when "pending"
      "En attente"
    when "approved"
      "Approuvée"
    when "rejected"
      "Refusée"
    else
      object.status.humanize
    end
  end

  def status_badge
    status_text = status
    case object.status
    when "pending"
      classes = "px-3 py-1 rounded-full text-sm font-semibold bg-blue-100 text-blue-700"
    when "approved"
      classes = "px-3 py-1 rounded-full text-sm font-semibold bg-green-100 text-green-700"
    when "rejected"
      classes = "px-3 py-1 rounded-full text-sm font-semibold bg-red-100 text-red-700"
    else
      classes = "px-3 py-1 rounded-full text-sm font-semibold bg-gray-100 text-gray-700"
    end
    
    helpers.content_tag(:span, status_text, class: classes)
  end

  def formatted_created_at
    return "" unless object.created_at

    I18n.l(object.created_at, format: :short)
  end
end

