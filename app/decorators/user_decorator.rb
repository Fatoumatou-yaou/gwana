class UserDecorator < ApplicationDecorator
  delegate_all

  def full_name
    return object.email if object.first_name.blank? && object.last_name.blank?
    [object.first_name, object.last_name].compact.join(" ")
  end

  def gwana_profile
    object.gwana_profile&.decorate
  end

  def formatted_created_at
    object.created_at.strftime("%d/%m/%Y")
  end

  def formatted_updated_at
    object.updated_at.strftime("%d/%m/%Y")
  end
end

