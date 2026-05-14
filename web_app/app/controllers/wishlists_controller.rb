class WishlistsController < ApplicationController
  before_action :set_wishlist, only: [:show, :edit, :update, :destroy]

  def index
    if current_telegram_id.present?
      @wishlists = Wishlist.where(telegram_id: current_telegram_id)
    else
      @wishlists = []
    end
  end

  def show
    @gifts = @wishlist.gifts.order(created_at: :desc)

    @is_owner = (@wishlist.user_id == current_user.id)

    redirect_to wishlists_path unless @is_owner || params[:public].present?
  end

  def new
    @wishlist = Wishlist.new
  end

  def create
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
    @wishlist.user_id == current_user.id
  end

  def wishlist_params
    params.require(:wishlist).permit(:name, :event_date)
  end
end