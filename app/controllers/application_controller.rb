# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Pundit::Authorization

  # Set locale
  before_action :set_locale

  # Handle Pundit errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def user_not_authorized
    flash[:alert] = t("pundit.not_authorized")
    redirect_to(request.referer || root_path)
  end
end
