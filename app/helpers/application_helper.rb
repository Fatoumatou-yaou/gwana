module ApplicationHelper
  include Chartkick::Helper

  def decorate(model_or_collection)
    if model_or_collection.respond_to?(:each) && !model_or_collection.is_a?(Draper::CollectionDecorator)
      Draper::CollectionDecorator.decorate(model_or_collection)
    elsif model_or_collection.respond_to?(:decorate) && !model_or_collection.is_a?(Draper::Decorator)
      model_or_collection.decorate
    else
      model_or_collection
    end
  end

  def decorated_current_user
    return nil unless current_user
    current_user.decorate
  end

  def field_error_message(object, field_name)
    return "" unless object.present?
    return "" unless object.respond_to?(:errors)
    
    # Vérifier si l'objet a des erreurs sur ce champ
    errors = object.errors[field_name]
    return "" unless errors.any?

    content_tag :div, class: "mt-1 text-sm text-red-600 flex items-center gap-1" do
      concat content_tag(:span, "⚠", class: "text-red-500")
      concat errors.first
    end
  end

  def field_error_class(object, field_name, base_classes = "")
    return base_classes unless object.present?
    return base_classes unless object.respond_to?(:errors)
    
    # Vérifier si l'objet a des erreurs sur ce champ
    errors = object.errors[field_name]
    return base_classes unless errors.any?

    error_classes = "border-red-500 focus:border-red-500 focus:ring-red-500"
    "#{base_classes} #{error_classes}".strip
  end

  def mentorship_request_path_for_user
    return new_user_session_path unless user_signed_in?

    if current_user.admin?
      admin_gwanas_path
    elsif current_user.gwana?
      gwanas_path
    elsif current_user.user?
      new_mentorship_request_path
    else
      new_user_session_path
    end
  end
end
