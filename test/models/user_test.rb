require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "has many tweets" do
    assert_equal [tweets(:one)], users(:one).tweets.to_a
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
