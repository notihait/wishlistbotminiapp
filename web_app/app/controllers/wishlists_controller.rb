class WishlistsController < ApplicationController
  before_action :set_wishlist, only: [:show, :edit, :update, :destroy]

  def index
    Rails.logger.debug "CURRENT TG ID: #{current_telegram_id.inspect}"

    if current_telegram_id.present?
      @wishlists = Wishlist
        .where(telegram_id: current_telegram_id)
        .order(event_date: :asc)
    else
      @wishlists = []
    end
  end

  def show
    @gifts = @wishlist.gifts.order(created_at: :desc)

    @is_owner = wishlist_owner?(@wishlist)

    unless @is_owner
      @is_public_view = true
    end
  end

  def new
    @wishlist = Wishlist.new
  end

  def create
    Rails.logger.debug "=== CREATE ==="
    Rails.logger.debug "PARAMS: #{params.inspect}"
    Rails.logger.debug "SESSION: #{session.inspect}"
    Rails.logger.debug "CURRENT TG ID: #{current_telegram_id.inspect}"

    @wishlist = Wishlist.new(wishlist_params)

    telegram_id =
      params[:telegram_id] ||
      session[:telegram_id]

    if telegram_id.present?
      @wishlist.telegram_id = telegram_id.to_i
    end

    Rails.logger.debug "WISHLIST TG ID: #{@wishlist.telegram_id.inspect}"

    if @wishlist.save
      redirect_to @wishlist
    else
      Rails.logger.debug @wishlist.errors.full_messages

      render :new, status: :unprocessable_entity
    end
  end

  def edit
    redirect_to wishlists_path unless wishlist_owner?(@wishlist)
  end

  def update
    unless wishlist_owner?(@wishlist)
      redirect_to wishlists_path
      return
    end

    if @wishlist.update(wishlist_params)
      redirect_to @wishlist
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless wishlist_owner?(@wishlist)
      redirect_to wishlists_path
      return
    end

    @wishlist.destroy

    redirect_to wishlists_path
  end

  private

  def set_wishlist
    @wishlist = Wishlist.find(params[:id])
  end

  def wishlist_params
    params.require(:wishlist).permit(
      :name,
      :event_date
    )
  end
end