class TelegramAuthController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def login
      user = params[:user]
      return head :bad_request unless user
  
      tg_user = TelegramUser.find_or_create_by(telegram_id: user[:id])
  
      session[:telegram_user_id] = tg_user.id
  
      render json: { ok: true }
    end
  end