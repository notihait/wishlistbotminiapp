class ApplicationController < ActionController::Base
  helper_method :current_telegram_id, :wishlist_owner?

  def current_telegram_id
    params[:telegram_id].presence&.to_i
  end

  def wishlist_owner?(wishlist)
    current_telegram_id.present? && wishlist.telegram_id == current_telegram_id
  end
end