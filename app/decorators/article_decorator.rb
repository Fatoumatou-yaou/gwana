class ArticleDecorator < ApplicationDecorator
  delegate_all

  def formatted_created_at
    return "" unless object.created_at

    I18n.l(object.created_at, format: :short)
  end

  def published_status
    object.published? ? "Publié" : "Brouillon"
  end

  def author
    object.author&.decorate
  end
end

