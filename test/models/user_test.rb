require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "has many tweets" do
    assert_equal [tweets(:one)], users(:one).tweets.to_a
  end

  test "can like, unlike, and check whether a tweet is liked" do
    user = users(:one)
    tweet = tweets(:two)

    assert_not user.liked?(tweet)

    assert_difference("Like.count", 1) do
      user.like(tweet)
    end
    assert user.liked?(tweet)

    assert_no_difference("Like.count") do
      user.like(tweet)
    end

    assert_difference("Like.count", -1) do
      user.unlike(tweet)
    end
    assert_not user.liked?(tweet)
  end

  test "destroys tweets and likes when the user is destroyed" do
    user = users(:one)
    own_tweet_like = Like.create!(user: user, tweet: tweets(:two))
    own_tweet_other_like = Like.create!(user: users(:two), tweet: tweets(:one))

    assert_difference("Tweet.count", -1) do
      assert_difference("Like.count", -2) do
        user.destroy!
      end
    end

    assert_not Tweet.exists?(tweets(:one).id)
    assert_not Like.exists?(own_tweet_like.id)
    assert_not Like.exists?(own_tweet_other_like.id)
  end

  test "stores passwords as a digest" do
    user = User.create!(uid: "charlie", password: "secret123", password_confirmation: "secret123")

    assert_not_equal "secret123", user.password_digest
    assert user.authenticate("secret123")
  end

  test "rejects duplicate user ids" do
    user = User.new(uid: users(:one).uid, password: "secret123")

    assert_not user.valid?
    assert_includes user.errors[:uid], "has already been taken"
  end
end
