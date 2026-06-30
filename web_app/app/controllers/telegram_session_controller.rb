class TelegramSessionController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def create
      init_data = params[:initData]
      return render json: { ok: false }, status: :bad_request if init_data.blank?
  
      telegram_id = extract_telegram_id_from_init_data(init_data)
  
      if telegram_id.present?
        session[:telegram_id] = telegram_id
  
        render json: {
          ok: true,
          telegram_id: telegram_id
        }
      else
        render json: { ok: false }, status: :unauthorized
      end
    end
  end