require "test_helper"

class TweetAppTest < ActionDispatch::IntegrationTest
  test "registers a user and stores an encrypted password" do
    assert_difference("User.count", 1) do
      post users_path, params: {
        user: {
          uid: "new-user",
          password: "secret123",
          password_confirmation: "secret123"
        }
      }
    end

    assert_redirected_to root_path
    assert_not_equal "secret123", User.find_by!(uid: "new-user").password_digest
  end

  test "does not register a user when password confirmation differs" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          uid: "mismatched-password-user",
          password: "secret123",
          password_confirmation: "different123"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "li", text: /confirmation/i
  end

  test "logs in, posts a tweet, and can like and unlike it" do
    user = User.create!(uid: "writer", password: "secret123")
    tweet = tweets(:one)

    post top_login_path, params: { uid: user.uid, password: "secret123" }
    assert_redirected_to root_path

    assert_difference("Tweet.count", 1) do
      post tweets_path, params: { tweet: { message: "Hello, Rails!" } }
    end
    assert_redirected_to root_path
    posted_tweet = user.tweets.order(:created_at).last

    assert_difference("Like.count", 1) do
      post likes_path, params: { tweet_id: tweet.id }
    end
    assert_redirected_to root_path

    get root_path
    assert_select "textarea"
    assert_select "a", text: /\Aいいね削除\z/, count: 1
    assert_select "a", text: /\Aいいね\z/, count: 2
    assert_select ".tweet-message", text: tweets(:two).message

    assert_difference("Like.count", -1) do
      delete like_path(user.likes.find_by!(tweet: tweet))
    end
    assert_redirected_to root_path

    get root_path
    assert_select "a", text: /\Aいいね\z/, count: 3
    assert_equal user, posted_tweet.user
  end

  test "views and updates the logged-in user's profile" do
    user = User.create!(uid: "profile-user", password: "secret123")
    post top_login_path, params: { uid: user.uid, password: "secret123" }

    get profile_path
    assert_response :success
    assert_select "dd", text: user.uid
    assert_select "dd", text: "未設定"

    patch profile_path, params: { user: { age: 25, uid: "changed-id" } }
    assert_redirected_to profile_path
    assert_equal 25, user.reload.age
    assert_equal "profile-user", user.uid
  end

  test "deletes the logged-in user's tweet and its likes" do
    user = User.create!(uid: "tweet-deleter", password: "secret123")
    like = users(:two).like(user.tweets.create!(message: "削除対象の投稿"))
    tweet = like.tweet
    post top_login_path, params: { uid: user.uid, password: "secret123" }

    assert_difference("Tweet.count", -1) do
      assert_difference("Like.count", -1) do
        delete tweet_path(tweet)
      end
    end

    assert_redirected_to root_path
    assert_not Tweet.exists?(tweet.id)
    assert_not Like.exists?(like.id)
  end

  test "deletes the logged-in user, their tweets, and related likes" do
    user = User.create!(uid: "account-deleter", password: "secret123")
    tweet = user.tweets.create!(message: "削除される投稿")
    owned_like = user.like(tweets(:two))
    other_like = users(:two).like(tweet)
    post top_login_path, params: { uid: user.uid, password: "secret123" }

    assert_difference("User.count", -1) do
      assert_difference("Tweet.count", -1) do
        assert_difference("Like.count", -2) do
          delete profile_path
        end
      end
    end

    assert_redirected_to root_path
    assert_not User.exists?(user.id)
    assert_not Tweet.exists?(tweet.id)
    assert_not Like.exists?(owned_like.id)
    assert_not Like.exists?(other_like.id)
  end

  test "requires login to view or update a profile" do
    get profile_path
    assert_redirected_to root_path

    get edit_profile_path
    assert_redirected_to root_path

    patch profile_path, params: { user: { age: 25 } }
    assert_redirected_to root_path
  end

  test "rejects a negative profile age" do
    user = User.create!(uid: "profile-user", password: "secret123")
    post top_login_path, params: { uid: user.uid, password: "secret123" }

    patch profile_path, params: { user: { age: -1 } }

    assert_response :unprocessable_entity
    assert_nil user.reload.age
  end

  test "does not allow duplicate user ids" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          uid: users(:one).uid,
          password: "secret123",
          password_confirmation: "secret123"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "does not show posting or like controls before login" do
    get root_path

    assert_response :success
    assert_select "textarea", count: 0
    assert_select "a", text: "いいね", count: 0
    assert_select "a", text: "いいね削除", count: 0
  end

  test "rejects posting and liking before login" do
    assert_no_difference("Tweet.count") do
      post tweets_path, params: { tweet: { message: "Not allowed" } }
    end
    assert_redirected_to root_path

    assert_no_difference("Like.count") do
      post likes_path, params: { tweet_id: tweets(:one).id }
    end
    assert_redirected_to root_path
  end
end
