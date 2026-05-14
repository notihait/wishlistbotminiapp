class GiftsController < ApplicationController
  before_action :set_wishlist
  before_action :check_owner
  before_action :set_gift, only: [:edit, :update, :destroy]

  def new
    @gift = @wishlist.gifts.build
  end

  def create
    @gift = @wishlist.gifts.build(gift_params)

    if @gift.save
      redirect_to @wishlist
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @gift.update(gift_params)
      redirect_to @wishlist
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @gift.destroy
    redirect_to @wishlist
  end

  private

  def set_wishlist
    @wishlist = Wishlist.find(params[:wishlist_id])
  end

  def set_gift
    @gift = @wishlist.gifts.find(params[:id])
  end

  def check_owner
    redirect_to wishlists_path unless wishlist_owner?(@wishlist)
  end

  def gift_params
    params.require(:gift).permit(
      :name,
      :price,
      :image_url,
      :link_url,
      :additional_info
    )
  end
end