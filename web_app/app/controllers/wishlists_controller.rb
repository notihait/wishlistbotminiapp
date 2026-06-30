class WishlistsController < ApplicationController
  before_action :authenticate_telegram_user!
  before_action :set_wishlist, only: [:show, :edit, :update, :destroy]

  def index
    return redirect_to root_path if current_telegram_id.blank?

    @wishlists = Wishlist.where(telegram_id: current_telegram_id)
  end

  def show
    @gifts = @wishlist.gifts.order(created_at: :desc)
  end

  def new
    return redirect_to wishlists_path if current_telegram_id.blank?

    @wishlist = Wishlist.new
  end

  def create
    return redirect_to wishlists_path if current_telegram_id.blank?

    @wishlist = Wishlist.new(wishlist_params)
    @wishlist.telegram_id = current_telegram_id

    if @wishlist.save
      redirect_to @wishlist
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    redirect_to wishlists_path unless owns?
  end

  def update
    return redirect_to wishlists_path unless owns?

    if @wishlist.update(wishlist_params)
      redirect_to @wishlist
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    return redirect_to wishlists_path unless owns?

    @wishlist.destroy
    redirect_to wishlists_path
  end

  private

  def set_wishlist
    @wishlist = Wishlist.find(params[:id])
  end

  def owns?
    return false if current_telegram_id.blank?
    @wishlist.telegram_id == current_telegram_id
  end

  def wishlist_params
    params.require(:wishlist).permit(:name, :event_date)
  end
end