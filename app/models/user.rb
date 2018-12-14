class User < ApplicationRecord
  has_many :articles

  validates :username, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, presence: true
  validates :email, presence: true, uniqueness: true

  def authenticate(username, password)
    user = User.find_by(username: username)
    if user && user.password == password
      user
    else
      nil
    end
  end
end
