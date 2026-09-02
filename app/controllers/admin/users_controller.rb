class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update]
  after_action :verify_authorized, except: [:index]
  after_action :verify_policy_scoped, only: [:index]

  def index
    users = policy_scope([:admin, User]).active.order(created_at: :desc)
    users = users.where(profile: params[:profile]) if params[:profile].present?
    @pagy, users = pagy(users)
    @users = decorate(users)
  end

  def show
    authorize [:admin, @user]
    @user = @user.decorate
  end

  def new
    @user = User.new
    @user.profile = :admin
    authorize [:admin, @user]
  end

  def create
    @user = User.new(user_params)
    @user.profile = :admin
    @user.is_verified = false
    authorize [:admin, @user]

    # Générer un mot de passe temporaire
    temp_password = SecureRandom.alphanumeric(12)
    @user.password = temp_password
    @user.password_confirmation = temp_password

    if @user.save
      # Envoyer le code OTP
      OtpService.send_otp(@user)
      
      # Envoyer les identifiants par email (TODO: créer un mailer)
      UserMailer.send_credentials(@user, temp_password).deliver_now if defined?(UserMailer)
      
      flash[:notice] = "Compte administrateur créé avec succès. Un code de vérification a été envoyé."
      redirect_to admin_user_path(@user)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize [:admin, @user]
  end

  def update
    authorize [:admin, @user]
    params_to_update = user_params
    if params_to_update[:password].blank?
      params_to_update.delete(:password)
      params_to_update.delete(:password_confirmation)
    end

    if @user.update(params_to_update)
      flash[:notice] = "Utilisateur mis à jour avec succès."
      redirect_to admin_user_path(@user)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :country_code,
      :profile,
      :gender,
      :is_verified,
      :password,
      :password_confirmation
    )
  end
end

