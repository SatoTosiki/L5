class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  
  helper_method :current_user
  private
    def current_user
      if session[:login_uid]
        User.find_by(uid: session[:login_uid])
      end
    end
  
  def require_login
    return if current_user

    redirect_to root_path, alert: "この操作にはログインが必要です。"
  end
end
