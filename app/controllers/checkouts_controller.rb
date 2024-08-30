class CheckoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_product_and_check_price, only: :show


  def show
    @cart_items = current_user.cart_items # Adjust based on your actual cart implementatio
      # Create the Checkout Session
    @checkout_session = current_user
                        .payment_processor
                        .checkout(
                          mode:       "payment",
                          line_items: format_line_items(params[:line_items])
                        )
  end

  def success
    @session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @line_items = Stripe::Checkout::Session.list_line_items(params[:session_id])
  end

  def cancel
    # Handle the canceled checkout
  end



  private

  def find_product_and_check_price
    product_id = params.dig(:line_items, 0, :product_id)
    @product = Product.find_by(id: product_id)

    redirect_to root_path and return if @product.nil?

    return if @product.stripe_price_id.present?

    redirect_to root_path and return
  end

  def format_line_items(line_items)
    line_items.map do |item|
      {
        price:    item[:price],
        quantity: item[:quantity]
      }
    end
  end
end
