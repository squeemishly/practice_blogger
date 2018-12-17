class CommentsController < ApplicationController
  before_action :determine_article
  before_action :determine_comment, only: [:edit, :update]

  def new
    @comment = Comment.new
  end

  def create
    @comment = Comment.create_comment(comment_params, @article, current_user)
    if @comment.body == ""
      flash[:alert] = "Please add a comment to continue"
      redirect_to new_article_comment_path(@article)
    else
      @comment.save
      redirect_to article_path(@article)
    end
  end

  def destroy
    if @comment.user == current_user || @article.user == current_user
      Comment.delete(params[:id])
      redirect_to article_path(@article)
    else
      render_404
    end
  end

  def edit
    if @comment.user != current_user
      render_404
    end
  end

  def update
    if @comment.user == current_user
      @comment.update(comment_params)
      redirect_to article_path(@article)
    else
      render_404
    end
  end

  private

    def comment_params
      params.require(:comment).permit(:body)
    end

    def determine_article
      @article = Article.find(params[:article_id])
    end

    def determine_comment
      @comment = Comment.find(params[:id])
    end

    def render_404
      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
        format.xml  { head :not_found }
        format.any  { head :not_found }
      end
    end
end
