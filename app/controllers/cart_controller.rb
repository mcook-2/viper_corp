class CartController < ApplicationController
  before_action :load_cart

  def show
    @render_cart = false
    @cart_items = @cart.cart_items || []
    product_ids = @cart_items.pluck(:product_id)
    @products = Product.where(id: product_ids).index_by(&:id)
  end

  def add_item # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @product = Product.find_by(id: params[:id])
    quantity = params[:quantity].to_i
    current_cart_item = @cart.cart_items.find_by(product_id: @product.id)
    if current_cart_item && quantity.positive?
      current_cart_item.update(quantity:)
    elsif quantity <= 0
      current_cart_item.destroy
    else
      @cart.cart_items.create(product: @product, quantity:)
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [turbo_stream.replace("cart",
                                                   partial: "cart/cart",
                                                   target:  "cart")]
      end
      format.html do
        redirect_to cart_path, notice: "Item added to cart"
      end
      format.json { render json: { success: true } }
    end
  end

  def update_item
    product_id = params[:product_id]
    quantity = params[:quantity].to_i
    @cart.update_item(product_id, quantity)
    redirect_to cart_path, notice: "Cart updated."
  end

  def remove_item
    Cart_item.find_by(id: params[:id]).destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("cart",
                                                  partial: "cart/cart",
                                                  locals:  { cart: @cart })
      end
    end
  end

  private

  def load_cart
    if session[:cart_id].present?
      @cart = Cart.find_by(id: session[:cart_id])
      merge_session_cart if @cart && session[:cart].present?
    else
      @cart = Cart.create(user: current_user)
      session[:cart_id] = @cart.id
    end
  end

  def merge_session_cart
    session_cart = Cart.new(session)
    session_cart.items.each do |item|
      @cart.add_item(item["product_id"], item["quantity"])
    end
    session.delete(:cart) # Clear session cart after merging
  end
end
