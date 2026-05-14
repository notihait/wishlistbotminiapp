class WishlistsController < ApplicationController
  before_action :set_wishlist, only: [:show, :edit, :update, :destroy]

  def index
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

    unless @is_owner || params[:public].present?
      redirect_to wishlists_path
    end
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
    params.require(:wishlist).permit(:name, :event_date)
  end
end