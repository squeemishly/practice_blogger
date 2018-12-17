class CommentsController < ApplicationController
  def new
    @article = Article.find(params[:article_id])
    @comment = Comment.new
  end

  def create
    @article = Article.find(params[:article_id])
    @comment = Comment.new(article: @article, user: current_user, body: params[:comment][:body])
    if @comment.body == ""
      flash[:alert] = "Please add a comment to continue"
      redirect_to new_article_comment_path(@article)
    else
      redirect_to article_path(@article)
    end
  end
end
