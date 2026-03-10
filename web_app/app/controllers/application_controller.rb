class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Получаем telegram_id текущего пользователя из Telegram Web App
  def current_telegram_id
    @current_telegram_id ||= begin
      telegram_id = nil
      
      # 1. Пытаемся получить из initData ПЕРВЫМ (Telegram Web App передает это автоматически)
      telegram_id = extract_telegram_id_from_init_data
      
      # 2. Если не получили, проверяем параметры запроса (если бот передал в URL)
      if telegram_id.nil? && params[:telegram_id].present?
        telegram_id_str = params[:telegram_id].to_s.strip
        telegram_id = telegram_id_str.to_i if telegram_id_str.match?(/^\d+$/) && telegram_id_str.to_i > 0
      end
      
      # 3. Затем заголовки
      if telegram_id.nil? && request.headers['X-Telegram-User-Id'].present?
        telegram_id = request.headers['X-Telegram-User-Id'].to_i
      end
      
      # 4. Или из сессии (если был сохранен ранее)
      if telegram_id.nil? && session[:telegram_id].present?
        telegram_id = session[:telegram_id].to_i
      end
      
      # 5. Или из cookies (если был сохранен через JavaScript)
      if telegram_id.nil? && cookies[:telegram_id].present?
        cookie_id = cookies[:telegram_id].to_s.strip
        telegram_id = cookie_id.to_i if cookie_id.match?(/^\d+$/) && cookie_id.to_i > 0
      end
      
      # Сохраняем в сессию, если получили из любого источника
      if telegram_id.present? && telegram_id > 0
        session[:telegram_id] = telegram_id unless session[:telegram_id] == telegram_id
        if Rails.env.development?
          Rails.logger.debug "=== SAVED TELEGRAM ID TO SESSION ==="
          Rails.logger.debug "telegram_id: #{telegram_id.inspect}"
          Rails.logger.debug "session[:telegram_id]: #{session[:telegram_id].inspect}"
        end
      end
      
      telegram_id
    end
  end
  
  # Извлекаем telegram_id из initData Telegram Web App
  def extract_telegram_id_from_init_data
    # Telegram Web App передает initData в параметрах или заголовках
    # Проверяем разные возможные источники
    init_data = params[:_auth] || 
                params[:initData] || 
                params[:tgWebAppData] ||
                request.headers['X-Telegram-Init-Data'] ||
                request.headers['X-Telegram-Web-App-Init-Data']
    
    if Rails.env.development? && init_data.present?
      Rails.logger.debug "=== EXTRACT TELEGRAM ID FROM INIT DATA ==="
      Rails.logger.debug "init_data present: #{init_data.present?}"
      Rails.logger.debug "init_data length: #{init_data.length if init_data}"
    end
    
    return nil if init_data.blank?
    
    # Парсим initData (это URL-encoded строка с параметрами)
    begin
      # initData имеет формат: query_string=value&user=%7B%22id%22%3A123456789%2C...%7D
      require 'uri'
      decoded = URI.decode_www_form(init_data).to_h
      
      if Rails.env.development?
        Rails.logger.debug "decoded keys: #{decoded.keys.inspect}"
      end
      
      # Ищем параметр user, который содержит JSON с данными пользователя
      if decoded['user'].present?
        user_data = JSON.parse(decoded['user'])
        telegram_id = user_data['id'].to_i if user_data['id'].present?
        if Rails.env.development?
          Rails.logger.debug "Found telegram_id from user: #{telegram_id.inspect}"
        end
        return telegram_id if telegram_id.present? && telegram_id > 0
      end
      
      # Альтернативно, проверяем параметр user_id напрямую
      if decoded['user_id'].present?
        telegram_id = decoded['user_id'].to_i
        if Rails.env.development?
          Rails.logger.debug "Found telegram_id from user_id: #{telegram_id.inspect}"
        end
        return telegram_id if telegram_id > 0
      end
    rescue => e
      Rails.logger.debug "Error parsing initData: #{e.message}" if Rails.env.development?
      Rails.logger.debug e.backtrace.first(5).join("\n") if Rails.env.development?
    end
    
    nil
  end
  
  # Сохраняем telegram_id в сессию и cookies при первом получении
  def save_telegram_id_to_session
    if current_telegram_id.present?
      if session[:telegram_id] != current_telegram_id
        session[:telegram_id] = current_telegram_id
      end
      if cookies[:telegram_id] != current_telegram_id.to_s
        cookies.permanent[:telegram_id] = { value: current_telegram_id.to_s, httponly: false }
      end
    end
  end
  
  before_action :save_telegram_id_to_session
  before_action :force_save_telegram_id_from_params
  
  # Проверяем, является ли текущий пользователь владельцем вишлиста
  def wishlist_owner?(wishlist)
    return false if wishlist.telegram_id.nil?
    
    # Если telegram_id не получен, разрешаем доступ (fallback для разработки)
    # В продакшене это должно быть строго проверено
    if current_telegram_id.nil?
      return true if Rails.env.development?
      return false
    end
    
    wishlist.telegram_id == current_telegram_id
  end
  
  helper_method :current_telegram_id, :wishlist_owner?
  
  # Принудительно сохраняем telegram_id из параметров URL в сессию
  def force_save_telegram_id_from_params
    if params[:telegram_id].present?
      telegram_id_str = params[:telegram_id].to_s.strip
      if telegram_id_str.match?(/^\d+$/) && telegram_id_str.to_i > 0
        telegram_id_int = telegram_id_str.to_i
        session[:telegram_id] = telegram_id_int
        cookies.permanent[:telegram_id] = { value: telegram_id_int.to_s, httponly: false }
        
        if Rails.env.development?
          Rails.logger.debug "=== FORCE SAVE TELEGRAM ID FROM PARAMS ==="
          Rails.logger.debug "params[:telegram_id]: #{params[:telegram_id].inspect}"
          Rails.logger.debug "Saved to session: #{session[:telegram_id].inspect}"
        end
      end
    end
  end
end
