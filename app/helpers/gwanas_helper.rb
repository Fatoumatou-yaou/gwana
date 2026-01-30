module GwanasHelper
  def mentorship_request_status_badge(status)
    case status.to_s
    when "pending"
      content_tag :span, "EN ATTENTE", class: "px-3 py-1 rounded-full text-xs font-semibold bg-yellow-100 text-yellow-800"
    when "accepted"
      content_tag :span, "ACCEPTÉE", class: "px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800"
    when "rejected"
      content_tag :span, "REFUSÉE", class: "px-3 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-800"
    when "completed"
      content_tag :span, "TERMINÉE", class: "px-3 py-1 rounded-full text-xs font-semibold bg-blue-100 text-blue-800"
    when "cancelled"
      content_tag :span, "ANNULÉE", class: "px-3 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-800"
    else
      content_tag :span, status.humanize, class: "px-3 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-800"
    end
  end

  def gwana_update_request_status_badge(status)
    case status.to_s
    when "pending"
      content_tag :span, "EN COURS", class: "px-3 py-1 rounded-full text-xs font-semibold bg-gray-800 text-white"
    when "approved"
      content_tag :span, "APPROUVÉE", class: "px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800"
    when "rejected"
      content_tag :span, "REFUSÉE", class: "px-3 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-800"
    else
      content_tag :span, status.humanize, class: "px-3 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-800"
    end
  end

  def format_request_date(date)
    return "" unless date
    l(date, format: "%d %b")
  end
end

