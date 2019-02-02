class ArticlesController < ApplicationController
  before_action :determine_article, only: [:show, :edit, :update, :destroy]

  def index
    @articles = Article.articles_to_display(params[:page], params[:limit])
  end

  def show
    @comments = Comment.comments_to_display(@article, params[:page])
  end

  def new
    if current_user
      @article = Article.new
    else
      render_403
    end
  end

  def create
    if current_user
      @article = Article.new(article_params)
      @article.user = current_user
      if @article.save
        redirect_to article_path(@article)
      else
        flash[:alert] = "Please finish writing your article!"
        render :new
      end
    else
      render_403
    end
  end

  def edit
    render_403 unless @article.user == current_user
  end

  def update
    if @article.user == current_user
      @article.update!(article_params)
      redirect_to article_path(@article.id)
    else
      render_403
    end
  end

  def destroy
    if @article.user == current_user || current_admin?
      Article.destroy(params[:id])
      redirect_to articles_path
    else
      render_403
    end
  end

  private

    def article_params
      params.require(:article).permit(:title, :body)
    end

    def determine_article
      @article = Article.find(params[:id])
    end
end
