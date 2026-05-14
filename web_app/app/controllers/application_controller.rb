class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= TelegramUser.find_by(id: session[:telegram_user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    redirect_to root_path unless logged_in?
  end

  def current_telegram_id
    current_user&.telegram_id
  end
end