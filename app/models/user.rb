class User < ApplicationRecord
  has_secure_password

  has_many :tweets, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :like_tweets, through: :likes, source: :tweet

  def like(tweet)
    likes.find_or_create_by!(tweet: tweet)
  end

  def unlike(tweet)
    likes.find_by(tweet: tweet)&.destroy
  end

  def liked?(tweet)
    likes.exists?(tweet_id: tweet.id)
  end

  validates :uid, presence: true, uniqueness: true
  validates :age, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
