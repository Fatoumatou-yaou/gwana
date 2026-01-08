class Users::SessionsController < Devise::SessionsController
  layout "auth"
  before_action :configure_sign_in_params, only: [:create]

  def create
    login = params[:user][:email] || params[:user][:phone]
    self.resource = User.find_for_database_authentication(login: login)
    password = params[:user][:password]

    if resource.nil?
      flash[:alert] = "Email ou numéro de téléphone invalide."
      redirect_to new_user_session_path and return
    end

    if !resource.is_verified?
      if resource.valid_password?(password)
        # Renvoyer le code OTP
        OtpService.send_otp(resource)
        redirect_to new_users_otp_path(email: resource.email) and return
      else
        flash[:alert] = "Mot de passe invalide."
        redirect_to new_user_session_path and return
      end
    else
      if resource.valid_password?(password)
        sign_in(resource_name, resource)
        respond_with resource, location: after_sign_in_path_for(resource)
      else
        flash[:alert] = "Email ou numéro de téléphone ou mot de passe invalide."
        redirect_to new_user_session_path
      end
    end
  end

  protected

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[email password])
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_dashboard_path
    else
      dashboard_path
    end
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end
end
