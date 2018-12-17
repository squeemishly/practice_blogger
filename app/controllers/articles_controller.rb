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
    if @article.user != current_user
      render_404
    end
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
    if @article.user == current_user
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
      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
        format.xml  { head :not_found }
        format.any  { head :not_found }
      end
    end
end
