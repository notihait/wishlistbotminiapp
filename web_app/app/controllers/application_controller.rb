class ApplicationController < ActionController::Base
  helper_method :current_user

  def current_user
    @current_user ||= TelegramUser.find_by(id: session[:telegram_user_id])
  end
end