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
    Comment.delete(params[:id])
    redirect_to article_path(@article)
  end

  def edit

  end

  def update
    @comment.update(comment_params)
    redirect_to article_path(@article)
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
end
