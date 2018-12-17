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
      @comment.save
      redirect_to article_path(@article)
    end
  end

  def destroy
    @article = Article.find(params[:article_id])
    Comment.delete(params[:id])
    redirect_to article_path(@article)
  end

  def edit
    @article = Article.find(params[:article_id])
    @comment = Comment.find(params[:id])
  end

  def update
    @article = Article.find(params[:article_id])
    @comment = Comment.find(params[:id])
    @comment.update(body: params[:comment][:body])
    redirect_to article_path(@article)
  end
end
