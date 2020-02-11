class ItemsController < ApplicationController

  before_action :set_item, except: [:index, :new, :create, :destroy]
  require "payjp"
  def index
    @item = Item.includes(:images).all.order(updated_at: :desc)
    @item2 = Item.includes(:images).all

  end

  def new
    @item = Item.new
    @item.images.new
  end

  def create
    @item =Item.new(item_params)
    if @item.save
      @item.update(seller_id: current_user.id)
      redirect_to root_path
    else
      @item.images.new
      render action: :new
      # redirect_to new_item_path
    end
  end

  def edit
    @item = Item.find(params[:id])
    @image = @item.images
  end

  def show
    @item = Item.find(params[:id])
    @image = @item.images
  end

  def update    
  if @item.update(item_params)
      flash[:notice] = "商品「#{@item.name}」を編集しました。"
      redirect_to
    else
      flash[:notice] = "必須項目が空欄です。"
      render :edit
    end
  end

  def destroy
    @item = Item.find(params[:id])
    if user_signed_in? && current_user.id == @item.seller_id && @item.destroy
      flash[:notice] = "商品「#{@item.name}」を削除しました。"
      redirect_to root_path  
    else
      flash[:notice] = "削除できません。"
      redirect_to root_path
    end
  end

  def purchase
    @item = Item.find(params[:id])
    @user = User.find(current_user.id)
    # @user = User.find(2)
    @address = @item.user.addresses
    card = Credit.where(user_id: current_user.id).first
    # card = Credit.where(user_id: 1).first
    if card.blank?
      redirect_to "/users/add"
    else
      Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
      customer = Payjp::Customer.retrieve(card.customer_id)
      @default_card_information = customer.cards.retrieve(card.card_id)
      render :layout => "mailer.text"
    end
  end

  private
  def item_params
    params.require(:item).permit(:name, :like, :price, :status, :brand, :descripstion, :burden, :method, :area_id, :category_id, :brand_id, :seller_id, :buyer_id, images_attributes: [:images, :_destroy, :id]).merge(user_id: current_user.id)
  end
  def set_item
    @item = Item.find(params[:id])
  end
end
