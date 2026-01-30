class GwanaActivityDecorator < ApplicationDecorator
  delegate_all

  def gwana
    object.gwana&.decorate
  end
end

