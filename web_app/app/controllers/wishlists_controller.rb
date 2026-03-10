class WishlistsController < ApplicationController
  before_action :set_wishlist, only: [:show, :edit, :update, :destroy, :share]
  skip_before_action :verify_authenticity_token, only: [:show] # Для публичного доступа

  def index
    @wishlists = Wishlist.order(event_date: :asc)
  end

  def show
    @gifts = @wishlist.gifts.order(created_at: :desc)
    @is_public_view = params[:public] == 'true'
    @is_owner = wishlist_owner?(@wishlist)
  end

  def new
    @wishlist = Wishlist.new
  end

  def create
    @wishlist = Wishlist.new(wishlist_params)
    
    # КРИТИЧНО: Получаем telegram_id из сессии ПЕРВЫМ делом (она должна быть сохранена при GET запросах)
    telegram_id = session[:telegram_id]&.to_i
    
    # Если в сессии нет, пробуем получить из current_telegram_id
    if telegram_id.nil? || telegram_id == 0
      telegram_id = current_telegram_id
    end
    
    # Если все еще нет, пробуем получить из params напрямую
    if (telegram_id.nil? || telegram_id == 0) && params[:telegram_id].present?
      telegram_id_str = params[:telegram_id].to_s.strip
      telegram_id = telegram_id_str.to_i if telegram_id_str.match?(/^\d+$/) && telegram_id_str.to_i > 0
      
      # Если получили из params, сохраняем в сессию
      if telegram_id.present? && telegram_id > 0
        session[:telegram_id] = telegram_id
        cookies.permanent[:telegram_id] = { value: telegram_id.to_s, httponly: false }
      end
    end
    
    # DEBUG: логируем для отладки
    if Rails.env.development?
      Rails.logger.debug "=== CREATE WISHLIST DEBUG ==="
      Rails.logger.debug "params: #{params.inspect}"
      Rails.logger.debug "params[:telegram_id]: #{params[:telegram_id].inspect}"
      Rails.logger.debug "params[:wishlist]: #{params[:wishlist].inspect}"
      Rails.logger.debug "request.headers['X-Telegram-User-Id']: #{request.headers['X-Telegram-User-Id'].inspect}"
      Rails.logger.debug "request.headers['X-Telegram-Init-Data']: #{request.headers['X-Telegram-Init-Data'].inspect}"
      Rails.logger.debug "session[:telegram_id]: #{session[:telegram_id].inspect}"
      Rails.logger.debug "session keys: #{session.keys.inspect}"
      Rails.logger.debug "cookies[:telegram_id]: #{cookies[:telegram_id].inspect}"
      Rails.logger.debug "current_telegram_id: #{current_telegram_id.inspect}"
      Rails.logger.debug "wishlist_params: #{wishlist_params.inspect}"
      Rails.logger.debug "telegram_id (final): #{telegram_id.inspect}"
      Rails.logger.debug "extract_telegram_id_from_init_data: #{extract_telegram_id_from_init_data.inspect}"
    end
    
    # Устанавливаем telegram_id только если он валидный (больше 0)
    if telegram_id.present? && telegram_id.to_i > 0
      @wishlist.telegram_id = telegram_id.to_i
      Rails.logger.debug "Set wishlist.telegram_id to: #{@wishlist.telegram_id.inspect}" if Rails.env.development?
    else
      Rails.logger.debug "telegram_id is invalid or missing, not setting" if Rails.env.development?
    end
    
    if @wishlist.save
      redirect_to @wishlist, notice: 'Вишлист успешно создан.'
    else
      render :new
    end
  end

  def edit
    unless wishlist_owner?(@wishlist)
      redirect_to @wishlist, alert: 'У вас нет прав для редактирования этого вишлиста.'
      return
    end
  end

  def update
    unless wishlist_owner?(@wishlist)
      redirect_to @wishlist, alert: 'У вас нет прав для редактирования этого вишлиста.'
      return
    end
    
    if @wishlist.update(wishlist_params)
      redirect_to @wishlist, notice: 'Вишлист успешно обновлен.'
    else
      render :edit
    end
  end

  def destroy
    unless wishlist_owner?(@wishlist)
      redirect_to @wishlist, alert: 'У вас нет прав для удаления этого вишлиста.'
      return
    end
    
    @wishlist.destroy
    redirect_to wishlists_path, notice: 'Вишлист успешно удален.', status: :see_other
  end

  def share
    # Генерируем ссылку для бота
    bot_username = ENV['BOT_USERNAME'] || 'my_wishlists_bot'
    share_url = "https://t.me/#{bot_username}?start=#{@wishlist.id}"
    render json: { share_url: share_url, wishlist_id: @wishlist.id }
  end

  private

  def set_wishlist
    @wishlist = Wishlist.find(params[:id])
  end

  def wishlist_params
    params.require(:wishlist).permit(:name, :event_date, :telegram_id)
  end
end
