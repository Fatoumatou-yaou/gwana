class NetworkEventDecorator < ApplicationDecorator
  delegate_all

  def formatted_created_at
    return "" unless object.created_at

    I18n.l(object.created_at, format: :short)
  end

  def formatted_event_date
    return "" unless object.event_date

    I18n.l(object.event_date, format: :short)
  end

  def photos_count
    object.photos_count
  end
end

