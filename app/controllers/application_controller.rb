class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Pundit::Authorization
  include Pagy::Backend

  # Set locale
  before_action :set_locale

  # Handle Pundit errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def decorate(model_or_collection)
    if model_or_collection.respond_to?(:each) && !model_or_collection.is_a?(Draper::CollectionDecorator)
      Draper::CollectionDecorator.decorate(model_or_collection)
    elsif model_or_collection.respond_to?(:decorate) && !model_or_collection.is_a?(Draper::Decorator)
      model_or_collection.decorate
    else
      model_or_collection
    end
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {}
  end

  def user_not_authorized
    flash[:alert] = "Vous n'êtes pas autorisé à effectuer cette action."
    redirect_to(request.referer || root_path)
  end

  def authenticate_user!(options = {})
    unless user_signed_in?
      flash[:alert] = "Vous devez vous connecter pour acceder à cette page"
    end
    super
  end
end
