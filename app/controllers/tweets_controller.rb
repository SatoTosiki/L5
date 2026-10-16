class TweetsController < ApplicationController
  before_action :require_login

  def create
    @tweet = current_user.tweets.build(tweet_params)

    if @tweet.save
      redirect_to root_path, notice: "ツイートを投稿しました。"
    else
      redirect_to root_path, alert: @tweet.errors.full_messages.to_sentence
    end
  end

  private

  def tweet_params
    params.require(:tweet).permit(:message)
  end
end
