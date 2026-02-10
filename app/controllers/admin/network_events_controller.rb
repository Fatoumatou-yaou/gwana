class Admin::NetworkEventsController < Admin::BaseController
  before_action :set_network_event, only: [:show, :edit, :update, :destroy]

  def index
    network_events = policy_scope([:admin, NetworkEvent]).recent
    network_events = network_events.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    @pagy, network_events = pagy(network_events)
    @network_events = decorate(network_events)
  end

  def show
    authorize [:admin, @network_event]
    @network_event = @network_event.decorate
  end

  def new
    @network_event = NetworkEvent.new
    authorize [:admin, @network_event]
  end

  def create
    @network_event = NetworkEvent.new(network_event_params)
    authorize [:admin, @network_event]

    if @network_event.save
      flash[:notice] = "Événement créé avec succès."
      redirect_to admin_network_event_path(@network_event)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize [:admin, @network_event]
  end

  def update
    authorize [:admin, @network_event]
    if @network_event.update(network_event_params)
      flash[:notice] = "Événement mis à jour avec succès."
      redirect_to admin_network_event_path(@network_event)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize [:admin, @network_event]
    @network_event.destroy
    flash[:notice] = "Événement supprimé avec succès."
    redirect_to admin_network_events_path
  end

  private

  def set_network_event
    @network_event = NetworkEvent.find(params[:id])
  end

  def network_event_params
    params.require(:network_event).permit(:name, :description, :event_date, photos: [])
  end
end

