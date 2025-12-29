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
end
