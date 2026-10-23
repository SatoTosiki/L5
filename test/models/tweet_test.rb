require "test_helper"

class TweetTest < ActiveSupport::TestCase
  test "belongs to a user" do
    assert_equal users(:one), tweets(:one).user
  end

  test "cannot be liked more than once by the same user" do
    Like.create!(user: users(:one), tweet: tweets(:two))
    duplicate_like = Like.new(user: users(:one), tweet: tweets(:two))

    assert_not duplicate_like.valid?
  end

  test "destroys likes when the tweet is destroyed" do
    like = Like.create!(user: users(:two), tweet: tweets(:one))

    assert_difference("Like.count", -1) do
      tweets(:one).destroy!
    end

    assert_not Like.exists?(like.id)
  end
end
