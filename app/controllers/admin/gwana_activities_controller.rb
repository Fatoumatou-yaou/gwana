class Admin::GwanaActivitiesController < Admin::BaseController
  before_action :set_gwana
  before_action :set_activity, only: [ :show, :edit, :update, :destroy ]

  def index
    @activities = policy_scope(@gwana.activities).includes(:gwana).recent
    @pagy, @activities = pagy(@activities)
    @activities = decorate(@activities)
  end

  def show
    authorize [ :admin, @activity ]
    redirect_to edit_admin_gwana_activity_path(@gwana, @activity)
  end

  def new
    @activity = @gwana.activities.build
    authorize [ :admin, @activity ]
  end

  def create
    @activity = @gwana.activities.build(activity_params)
    authorize [ :admin, @activity ]

    if @activity.save
      redirect_to admin_gwana_path(@gwana), notice: "Activité créée avec succès"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize [ :admin, @activity ]
  end

  def update
    authorize [ :admin, @activity ]

    if @activity.update(activity_params)
      redirect_to admin_gwana_path(@gwana), notice: "Activité mise à jour avec succès"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize [ :admin, @activity ]
    @activity.destroy
    redirect_to admin_gwana_path(@gwana), notice: "Activité supprimée avec succès"
  end

  private

  def set_gwana
    @gwana = decorate(Gwana.friendly.find(params[:gwana_id]))
  end

  def set_activity
    @activity = @gwana.activities.find(params[:id])
  end

  def activity_params
    params.require(:gwana_activity).permit(
      :activity_type,
      :activity_date,
      :youtube_video_id,
      :description,
      photos: []
    )
  end
end
