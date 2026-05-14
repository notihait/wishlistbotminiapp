class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :set_telegram_user

  helper_method :current_telegram_id, :wishlist_owner?

  private

  def set_telegram_user
    if params[:telegram_id].present?
      session[:telegram_id] = params[:telegram_id].to_i
    end
  end

  def current_telegram_id
    session[:telegram_id]
  end

  def wishlist_owner?(wishlist)
    return false if current_telegram_id.blank?

    wishlist.telegram_id == current_telegram_id
  end
end