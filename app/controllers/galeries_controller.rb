class GaleriesController < ApplicationController
  layout "slim"
  def index
    @featured_event = NetworkEvent.recent.first
    @other_events = NetworkEvent.recent.offset(1).limit(12) if @featured_event
  end
end

