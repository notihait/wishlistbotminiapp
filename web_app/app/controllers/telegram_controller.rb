class TelegramController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :save_id

  def save_id
    telegram_id = params[:telegram_id].to_s.strip

    unless telegram_id.match?(/^\d+$/)
      return render json: { status: "error" }, status: :bad_request
    end

    telegram_id = telegram_id.to_i

    session[:telegram_id] = telegram_id

    cookies.permanent[:telegram_id] = {
      value: telegram_id,
      httponly: false
    }

    render json: {
      status: "ok",
      telegram_id: telegram_id
    }
  end
end