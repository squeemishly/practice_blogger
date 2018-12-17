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
end
