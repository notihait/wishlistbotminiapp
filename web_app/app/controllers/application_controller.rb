class ApplicationController < ActionController::Base
  helper_method :current_telegram_id, :wishlist_owner?

  def current_telegram_id
    session[:telegram_id]
  end

  private

  # вызываем один раз из before_action
  def authenticate_telegram_user!
    return if session[:telegram_id].present?

    init_data = params[:initData] || request.headers["X-Telegram-Init-Data"]
    return if init_data.blank?

    telegram_id = extract_telegram_id_from_init_data(init_data)

    if telegram_id.present?
      session[:telegram_id] = telegram_id
    end
  end

  # ⚠️ упрощённый парсер (без полной проверки подписи)
  # если хочешь — дам версию с HMAC verification (production-safe)
  def extract_telegram_id_from_init_data(init_data)
    parsed = CGI.parse(init_data)
    user_json = parsed["user"]&.first
    return nil if user_json.blank?

    JSON.parse(user_json)["id"].to_i
  rescue
    nil
  end

  def wishlist_owner?(wishlist)
    wishlist.telegram_id.present? &&
      wishlist.telegram_id == current_telegram_id
  end
end