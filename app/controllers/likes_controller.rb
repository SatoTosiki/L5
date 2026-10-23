class LikesController < ApplicationController
  before_action :require_login

  def create
    tweet = Tweet.find(params[:tweet_id])
    current_user.like(tweet) unless current_user.liked?(tweet)
    redirect_to root_path
  end

  def destroy
    like = current_user.likes.find(params[:id])
    current_user.unlike(like.tweet)
    redirect_to root_path
  end
end