class Admin::ArticlesController < Admin::BaseController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  def index
    articles = policy_scope(Article).includes(:author).order(created_at: :desc)
    articles = articles.search_by_text(params[:search]) if params[:search].present?
    articles = articles.by_category(params[:category]) if params[:category].present?
    articles = articles.with_photo if params[:media_type] == "photo"
    articles = articles.with_video if params[:media_type] == "video"
    @pagy, articles = pagy(articles)
    @articles = decorate(articles)
  end

  def show
    authorize [:admin, @article]
    @article = @article.decorate
  end

  def new
    @article = Article.new
    authorize [:admin, @article]
  end

  def create
    @article = Article.new(article_params)
    @article.author = current_user
    authorize [:admin, @article]

    if @article.save
      flash[:notice] = "Article créé avec succès."
      redirect_to admin_article_path(@article)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize [:admin, @article]
  end

  def update
    authorize [:admin, @article]
    if @article.update(article_params)
      flash[:notice] = "Article mis à jour avec succès."
      redirect_to admin_article_path(@article)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize [:admin, @article]
    @article.destroy
    flash[:notice] = "Article supprimé avec succès."
    redirect_to admin_articles_path
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :content, :published, :category, :tags, :media_type, :photo, :video)
  end
end

