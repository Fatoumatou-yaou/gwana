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
    @profile = params[:profile] || "gwana"
    @user.profile = @profile
    authorize [:admin, @user]
  end

  def create
    @user = User.new(user_params)
    @user.profile = params[:user][:profile] || "gwana"
    @user.is_verified = false
    authorize [:admin, @user]

    # Empêcher la création de user
    if @user.profile == "user"
      @profile = @user.profile
      flash[:alert] = "Vous ne pouvez créer que des comptes admin ou gwana."
      render :new, status: :unprocessable_entity
      return
    end

    # Générer un mot de passe temporaire
    temp_password = SecureRandom.alphanumeric(12)
    @user.password = temp_password
    @user.password_confirmation = temp_password

    if @user.save
      # Envoyer le code OTP
      OtpService.send_otp(@user)
      
      # Envoyer les identifiants par email (TODO: créer un mailer)
      UserMailer.send_credentials(@user, temp_password).deliver_now if defined?(UserMailer)
      
      flash[:notice] = "#{@user.profile.capitalize} créé(e) avec succès. Un code de vérification a été envoyé."
      redirect_to admin_user_path(@user)
    else
      @profile = @user.profile
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize [:admin, @user]
  end

  def update
    authorize [:admin, @user]
    if @user.update(user_params)
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
    params.require(:user).permit(:email, :first_name, :last_name, :phone, :country_code, :profile)
  end
end

