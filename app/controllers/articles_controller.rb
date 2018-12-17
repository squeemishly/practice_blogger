class ArticlesController < ApplicationController
  before_action :determine_article, only: [:show, :edit, :update]

  def index
    @articles = Article.all.reverse
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
      redirect_to root_path
    else
      flash[:alert] = "Please finish writing your article!"
      render :new
    end
  end

  def edit

  end

  def update
    @article.update!(article_params)
    redirect_to article_path(@article.id)
  end

  def destroy
    Article.delete(params[:id])
    redirect_to articles_path
  end

  private

    def article_params
      params.require(:article).permit(:title, :body)
    end

    def determine_article
      @article = Article.find(params[:id])
    end
end
