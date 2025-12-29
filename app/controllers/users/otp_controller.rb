class Users::OtpController < ApplicationController
  layout "slim"
  before_action :set_user, only: [:create, :resend]

  def new
    @email = params[:email]
    @user = User.find_by(email: @email) if @email.present?
    
    unless @user
      redirect_to new_user_session_path, alert: "Email invalide."
    end
  end

  def create
    code = params[:otp_code]
    
    if code.blank?
      flash[:alert] = "Veuillez entrer le code de vérification."
      render :new, status: :unprocessable_entity
      return
    end

    if OtpService.verify_otp(@user, code)
      sign_in(@user)
      flash[:notice] = "Votre compte a été vérifié avec succès."
      redirect_to after_verification_path_for(@user)
    else
      flash[:alert] = "Code de vérification invalide ou expiré."
      render :new, status: :unprocessable_entity
    end
  end

  def resend
    OtpService.resend_otp(@user)
    flash[:notice] = "Un nouveau code de vérification a été envoyé à votre adresse email."
    redirect_to new_users_otp_path(email: @user.email), notice: "Un nouveau code de vérification a été envoyé à votre adresse email."
  end

  private

  def set_user
    @email = params[:email] || (params[:user] && params[:user][:email])
    @user = User.find_by(email: @email) if @email.present?
    
    unless @user
      redirect_to new_user_session_path, alert: "Email invalide."
    end
  end

  def after_verification_path_for(user)
    if user.admin?
      admin_dashboard_path
    else
      dashboard_path
    end
  end
end

