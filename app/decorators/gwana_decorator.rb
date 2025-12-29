class GwanaDecorator < ApplicationDecorator
  delegate_all

  def full_name
    "#{object.first_name} #{object.last_name}".humanize
  end

  def formatted_created_at
    return "" unless object.created_at

    I18n.l(object.created_at, format: :short)
  end
end

