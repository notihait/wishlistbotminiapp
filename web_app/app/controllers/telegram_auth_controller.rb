class TelegramAuthController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:login]
  
    def login
      user_data = params[:user]
      return head :bad_request if user_data.blank?
  
      user = TelegramUser.find_or_create_by(telegram_id: user_data[:id])
  
      session[:telegram_user_id] = user.id
  
      render json: { ok: true }
    end
  end