
class GwanasController < ApplicationController
  layout "slim"
  before_action :set_gwana, only: [:show]

  def index
    gwanas = Gwana.all
    gwanas = gwanas.search_by_text(params[:search]) if params[:search].present?
    gwanas = gwanas.by_region(params[:region]) if params[:region].present?
    gwanas = gwanas.by_profession(params[:profession]) if params[:profession].present?
    gwanas = gwanas.available_for_mentorship if params[:available] == "true"
    gwanas = gwanas.order(:first_name, :last_name)
    @gwanas = decorate(gwanas)
  end

  def show
    authorize @gwana
    @gwana = @gwana.decorate
  end

  private

  def set_gwana
    @gwana = Gwana.friendly.find(params[:id])
  end
end

