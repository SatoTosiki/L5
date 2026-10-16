class TopController < ApplicationController
  def main
    @tweets = Tweet.includes(:user).order(created_at: :desc)
    @tweet = Tweet.new
    @likes_by_tweet_id = current_user.likes.index_by(&:tweet_id) if current_user
  end

  def login
    user = User.find_by(uid: params[:uid])

    if user&.authenticate(params[:password])
      reset_session
      session[:login_uid] = user.uid
      redirect_to root_path, notice: "ログインしました。"
    else
      redirect_to root_path, alert: "ユーザーIDまたはパスワードが正しくありません。"
    end
  end

  def logout
    reset_session
    redirect_to root_path, notice: "ログアウトしました。"
  end
end
