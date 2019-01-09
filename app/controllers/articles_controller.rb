class ArticlesController < ApplicationController
  before_action :determine_article, only: [:show, :edit, :update, :destroy]

  def index
    @articles = Article.articles_to_display(params[:page], params[:limit])
  end

  def show

  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)
    @article.user = current_user
    if @article.save
      redirect_to article_path(@article.id)
    else
      flash[:alert] = "Please finish writing your article!"
      render :new
    end
  end

  def edit
    render_404 unless @article.user == current_user
  end

  def update
    if @article.user == current_user
      @article.update!(article_params)
      redirect_to article_path(@article.id)
    else
      render_404
    end
  end

  def destroy
    if @article.user == current_user || current_admin?
      Article.delete(params[:id])
      redirect_to articles_path
    else
      render_404
    end
  end

  private

    def article_params
      params.require(:article).permit(:title, :body)
    end

    def determine_article
      @article = Article.find(params[:id])
    end

    def render_404
      render file: "/public/404", status: 404
    end
end
