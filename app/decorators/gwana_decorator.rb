class GwanaDecorator < ApplicationDecorator
  delegate_all

  def full_name
    "#{object.first_name} #{object.last_name}".humanize
  end

  def formatted_created_at
    return "" unless object.created_at

    I18n.l(object.created_at, format: :short)
  end

  def commune
    object.commune&.name || "non fourni"
  end

  def available_for_mentorship
    if object.available_for_mentorship?
      helpers.content_tag(:span, "Oui", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800")
    else
      helpers.content_tag(:span, "Non", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800")
    end
  end
end

