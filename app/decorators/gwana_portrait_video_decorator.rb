class GwanaPortraitVideoDecorator < ApplicationDecorator
  delegate_all

  def gwana
    object.gwana&.decorate
  end

  def youtube_embed_url
    object.youtube_embed_url
  end

  def youtube_thumbnail_url
    object.youtube_thumbnail_url
  end

  def formatted_created_at
    return "" unless object.created_at

    I18n.l(object.created_at, format: :short)
  end
end

