class Users::RegistrationsController < Devise::RegistrationsController
  layout "auth"
  before_action :configure_sign_up_params, only: [:create]
  before_action :ensure_user_profile_only, only: [:create]

  def create
    build_resource(sign_up_params.merge(profile: :user, is_verified: false))

    resource.save
    yield resource if block_given?
    
    if resource.persisted?
      if resource.active_for_authentication?
        # Envoyer le code OTP
        OtpService.send_otp(resource)
        set_flash_message! :notice, :signed_up_but_unverified
        redirect_to new_users_otp_path(email: resource.email)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation, :phone, :country_code, :first_name, :last_name, :gender, :date_of_birth])
  end

  def ensure_user_profile_only
    # Seuls les users peuvent s'inscrire eux-mêmes
    if params[:user] && params[:user][:profile].present? && params[:user][:profile] != "user"
      redirect_to new_user_registration_path, alert: "Vous ne pouvez créer que des comptes utilisateur."
      return
    end
  end

  def after_sign_up_path_for(_resource)
    new_users_otp_path
  end

  def after_inactive_sign_up_path_for(_resource)
    new_users_otp_path
  end
end
