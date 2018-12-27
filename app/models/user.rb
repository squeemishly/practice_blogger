class User < ApplicationRecord
  has_many :articles, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, :presence =>true, :length => { :within => 8..50 }, :on => :create
  validates :email, presence: true, uniqueness: true

  has_secure_password

  enum role: [:default, :admin]
end
