class ArticlesController < ApplicationController
  def index
    @articles = Article.all.reverse
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(title: params[:article][:title], body: params[:article][:body], user_id: current_user.id)
    if @article.save
      redirect_to root_path
    else
      flash[:alert] = "Please finish writing your article!"
      render :new
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    @article.update(title: params[:article][:title], body: params[:article][:body])
    redirect_to article_path(@article.id)
  end

  def destroy
    Article.delete(params[:id])
    redirect_to articles_path
  end
end
