class Comment < ApplicationRecord
  belongs_to :article
  belongs_to :user

  validates :body, presence: true

  def self.create_comment(comment_params, article, user)
    comment = new(comment_params)
    comment.article = article
    comment.user = user
    comment
  end

  def self.comments_to_display(article, page_number, limit = 5)
    page_number = page_number ||= 1

    comments = article.comments.order(created_at: :desc)
    Kaminari.paginate_array(comments).page(page_number).per(limit)
  end
end
