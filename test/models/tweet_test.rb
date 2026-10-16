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
end
