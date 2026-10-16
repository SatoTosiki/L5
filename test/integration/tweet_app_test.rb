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
