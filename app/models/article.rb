class Article < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :delete_all

  validates :title, presence: true
  validates :body, presence: true

  def self.articles_to_display(page_number, limit)
    page_number = page_number ||= 1
    limit = limit ||= 10

    articles_list = Article.order(created_at: :desc)
    Kaminari.paginate_array(articles_list).page(page_number).per(limit)
  end

  def self.most_comments
    joins(:comments).group(:id).order(count: :desc).limit(5)
  end
end
