# app/controllers/telegram_auth_controller.rb
class TelegramAuthController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:login]
  
    def login
      user_data = params[:user]
  
      return render json: { error: "no user" }, status: 400 if user_data.blank?
  
      telegram_id = user_data[:id]
  
      return render json: { error: "invalid id" }, status: 400 unless telegram_id.present?
  
      user = TelegramUser.find_or_create_by(telegram_id: telegram_id)
  
      user.update(
        username: user_data[:username],
        first_name: user_data[:first_name],
        last_name: user_data[:last_name]
      )
  
      session[:telegram_user_id] = user.id
  
      render json: {
        status: "ok",
        user_id: user.id,
        telegram_id: user.telegram_id
      }
    end
  end