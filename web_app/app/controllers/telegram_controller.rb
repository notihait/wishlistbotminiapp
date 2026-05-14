class TelegramController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:save_id]
  
  # Метод extract_telegram_id_from_init_data наследуется от ApplicationController
  
  # Сохраняем telegram_id в сессию при загрузке страницы
  def save_id
    telegram_id =
      request.request_parameters["telegram_id"] ||
      current_user
    telegram_id = telegram_id.to_s.strip
  
    if telegram_id.match?(/^\d+$/) && telegram_id.to_i > 0
      telegram_id_int = telegram_id.to_i
  
      session[:telegram_id] = telegram_id_int
      cookies.permanent[:telegram_id] = {
        value: telegram_id_int.to_s,
        httponly: false
      }
  
      Rails.logger.debug "TG ID saved: #{telegram_id_int}"
  
      render json: { status: "ok", telegram_id: telegram_id_int }
    else
      render json: { status: "error" }, status: :bad_request
    end
  end
end

