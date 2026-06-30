class ApplicationController < ActionController::Base
  helper_method :current_telegram_id, :wishlist_owner?

  def current_telegram_id
    session[:telegram_id]
  end

  def authenticate_telegram_user!
    return if current_telegram_id.present?

    render json: { error: "unauthorized" }, status: :unauthorized
  end

  def wishlist_owner?(wishlist)
    wishlist.telegram_id.present? &&
      wishlist.telegram_id == current_telegram_id
  end

  # ⚠️ ВАЖНО: отдельный endpoint будет единственным источником auth
  def extract_telegram_id_from_init_data(init_data)
    data = CGI.parse(init_data)

    user = data["user"]&.first
    return nil unless user

    user = CGI.unescape(user)
    JSON.parse(user)["id"].to_i
  rescue
    nil
  end
end