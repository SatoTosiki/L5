class UsersController < ApplicationController
  before_action :require_login, only: %i[show edit update destroy]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to root_path, notice: "ユーザー登録が完了しました。ログインしてください。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(profile_params)
      redirect_to profile_path, notice: "プロフィールを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.destroy!
    reset_session
    redirect_to root_path, notice: "アカウントを削除しました。"
  end

  private

  def user_params
    params.require(:user).permit(:uid, :password, :password_confirmation)
  end

  def profile_params
    params.require(:user).permit(:age)
  end
end
