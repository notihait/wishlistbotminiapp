class GiftsController < ApplicationController
  before_action :set_wishlist
  before_action :set_gift, only: [:show, :edit, :update, :destroy]

  def index
    @gifts = @wishlist.gifts.order(created_at: :desc)
  end

  def show
  end

  def new
    unless wishlist_owner?(@wishlist)
      redirect_to @wishlist, alert: 'У вас нет прав для добавления подарков в этот вишлист.'
      return
    end
    @gift = @wishlist.gifts.build
  end

  def create
    unless wishlist_owner?(@wishlist)
      redirect_to @wishlist, alert: 'У вас нет прав для добавления подарков в этот вишлист.'
      return
    end
    
    @gift = @wishlist.gifts.build(gift_params)
    if @gift.save
      redirect_to @wishlist, notice: 'Подарок успешно добавлен.'
    else
      render :new
    end
  end

  def edit
    unless wishlist_owner?(@wishlist)
      redirect_to @wishlist, alert: 'У вас нет прав для редактирования подарков в этом вишлисте.'
      return
    end
  end

  def update
    unless wishlist_owner?(@wishlist)
      redirect_to @wishlist, alert: 'У вас нет прав для редактирования подарков в этом вишлисте.'
      return
    end
    
    if @gift.update(gift_params)
      redirect_to @wishlist, notice: 'Подарок успешно обновлен.'
    else
      render :edit
    end
  end

  def destroy
    unless wishlist_owner?(@wishlist)
      redirect_to @wishlist, alert: 'У вас нет прав для удаления подарков из этого вишлиста.'
      return
    end
    
    @gift.destroy
    redirect_to @wishlist, notice: 'Подарок успешно удален.', status: :see_other
  end

  private

  def set_wishlist
    @wishlist = Wishlist.find(params[:wishlist_id])
  end

  def set_gift
    @gift = @wishlist.gifts.find(params[:id])
  end

  def gift_params
    params.require(:gift).permit(:name, :price, :image_url, :link_url, :additional_info)
  end
end
