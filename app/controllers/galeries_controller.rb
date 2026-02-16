class GaleriesController < ApplicationController
  layout "slim"

  def index
    @featured_event = NetworkEvent.recent.first
    @other_events = NetworkEvent.recent.offset(1).limit(12) if @featured_event
  end

  def show
    @network_event = NetworkEvent.find(params[:id])
  end
end

