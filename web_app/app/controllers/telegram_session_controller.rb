class TelegramSessionController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def create

        Rails.logger.info("=== SET SESSION HIT ===")
Rails.logger.info("INIT DATA: #{params[:initData]}")

        init_data = params[:initData]
      
        Rails.logger.info("INIT_DATA: #{init_data}")
      
        return head :bad_request if init_data.blank?
      
        telegram_id = extract_telegram_id_from_init_data(init_data)
      
        Rails.logger.info("TELEGRAM_ID: #{telegram_id}")
      
        if telegram_id.present?
          session[:telegram_id] = telegram_id
          Rails.logger.info("SESSION SET: #{session[:telegram_id]}")
      
          render json: { ok: true, telegram_id: telegram_id }
        else
          render json: { ok: false }, status: :unauthorized
        end
      end
  
    private
  
    def extract_telegram_id_from_init_data(init_data)
      # Telegram initData = query string format
      # user=%7B...json...%7D&auth_date=...&hash=...
  
      parsed = CGI.parse(init_data)
  
      user_param = parsed["user"]&.first
      return nil unless user_param
  
      # decode URL-encoded JSON
      user_json = CGI.unescape(user_param)
  
      data = JSON.parse(user_json)
  
      data["id"]
    rescue => e
      Rails.logger.error("Telegram initData parse error: #{e.message}")
      nil
    end
  end