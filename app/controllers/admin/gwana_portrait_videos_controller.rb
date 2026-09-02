class Admin::GwanaPortraitVideosController < Admin::BaseController
  before_action :set_gwana
  before_action :set_portrait_video, only: [:show, :edit, :update, :destroy]

  def index
    @portrait_videos = policy_scope(@gwana.portrait_videos).includes(:gwana).ordered
    @pagy, @portrait_videos = pagy(@portrait_videos)
    @portrait_videos = decorate(@portrait_videos)
  end

  def show
    authorize [:admin, @portrait_video]
    redirect_to edit_admin_gwana_portrait_video_path(@gwana, @portrait_video)
  end

  def new
    @portrait_video = @gwana.portrait_videos.build
    @portrait_video.display_order = (@gwana.portrait_videos.maximum(:display_order) || 0) + 1
    authorize [:admin, @portrait_video]
  end

  def create
    @portrait_video = @gwana.portrait_videos.build(portrait_video_params)
    authorize [:admin, @portrait_video]

    if @portrait_video.save
      redirect_to admin_gwana_path(@gwana), notice: "Vidéo portrait créée avec succès"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize [:admin, @portrait_video]
  end

  def update
    authorize [:admin, @portrait_video]

    if @portrait_video.update(portrait_video_params)
      redirect_to admin_gwana_path(@gwana), notice: "Vidéo portrait mise à jour avec succès"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize [:admin, @portrait_video]
    @portrait_video.destroy
    redirect_to admin_gwana_path(@gwana), notice: "Vidéo portrait supprimée avec succès"
  end

  private

  def set_gwana
    @gwana = decorate(Gwana.friendly.find(params[:gwana_id]))
  end

  def set_portrait_video
    @portrait_video = @gwana.portrait_videos.find(params[:id])
  end

  def portrait_video_params
    params.require(:gwana_portrait_video).permit(
      :youtube_video_id,
      :teaser_text,
      :display_order
    )
  end
end

