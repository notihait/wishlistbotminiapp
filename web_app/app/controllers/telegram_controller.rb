class TelegramController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:save_id]
  
  # Метод extract_telegram_id_from_init_data наследуется от ApplicationController
  
  # Сохраняем telegram_id в сессию при загрузке страницы
  def save_id
    # Пробуем получить из разных источников
    telegram_id = nil
    
    # 1. Из JSON body (если запрос через fetch)
    if request.content_type&.include?('application/json')
      json_data = JSON.parse(request.body.read)
      telegram_id = json_data['telegram_id']&.to_s&.strip
    end
    
    # 2. Из параметров формы
    if telegram_id.blank?
      telegram_id = params[:telegram_id]&.to_s&.strip
    end
    
    # 3. Из initData (если доступен)
    if telegram_id.blank?
      telegram_id = extract_telegram_id_from_init_data
    end
    
    # Проверяем, что telegram_id валидный (только цифры и больше 0)
    if telegram_id.present? && telegram_id.to_s.match?(/^\d+$/) && telegram_id.to_i > 0
      telegram_id_int = telegram_id.to_i
      session[:telegram_id] = telegram_id_int
      cookies.permanent[:telegram_id] = { value: telegram_id_int.to_s, httponly: false }
      
      if Rails.env.development?
        Rails.logger.debug "=== SAVE TELEGRAM ID ==="
        Rails.logger.debug "telegram_id received: #{telegram_id.inspect}"
        Rails.logger.debug "telegram_id saved: #{telegram_id_int}"
        Rails.logger.debug "session[:telegram_id]: #{session[:telegram_id].inspect}"
        Rails.logger.debug "cookies[:telegram_id]: #{cookies[:telegram_id].inspect}"
      end
      
      if request.content_type&.include?('application/json')
        render json: { status: 'ok', telegram_id: telegram_id_int }
      else
        # Редирект обратно, если это форма
        redirect_back(fallback_location: root_path, notice: 'Telegram ID сохранен')
      end
    else
      if Rails.env.development?
        Rails.logger.debug "=== SAVE TELEGRAM ID FAILED ==="
        Rails.logger.debug "telegram_id: #{telegram_id.inspect}"
        Rails.logger.debug "params: #{params.inspect}"
      end
      
      if request.content_type&.include?('application/json')
        render json: { status: 'error', message: 'Invalid telegram_id' }, status: :bad_request
      else
        redirect_back(fallback_location: root_path, alert: 'Не удалось сохранить Telegram ID')
      end
    end
  end
end

