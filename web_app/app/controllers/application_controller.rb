class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= TelegramUser.find_by(id: session[:telegram_user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if current_user
  
    Rails.logger.debug "NO USER YET"
  end

  
  def current_telegram_id
    current_user&.telegram_id
  end
end