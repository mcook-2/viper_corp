class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :set_clothing_types

  before_action :set_render_cart
  before_action :initialize_cart

  def set_render_cart
    @render_cart = true
  end

  def initialize_cart
    if user_signed_in?
      @cart = Cart.find_by(id: session[:cart_id], user_id: current_user.id)

      if @cart.nil?
        flash[:notice] = "Cart not found for user, creating a new cart"
        @cart = Cart.create(user: current_user)
        if @cart.persisted?
          session[:cart_id] = @cart.id
          flash[:success] = "New cart created for user with ID: #{@cart.id}"
        else
          flash[:alert] = "Failed to create new cart: #{@cart.errors.full_messages.join(", ")}"
        end
      else
        flash[:notice] = "User cart found with ID: #{@cart.id}"
      end
    else
      @cart = Cart.find_by(id: session[:cart_id])

      if @cart.nil?
        flash[:notice] = "Cart not found, creating a new cart"
        @cart = Cart.create
        if @cart.persisted?
          session[:cart_id] = @cart.id
          flash[:success] = "New cart created with ID: #{@cart.id}"
        else
          flash[:alert] = "Failed to create new cart: #{@cart.errors.full_messages.join(", ")}"
        end
      else
        flash[:notice] = "Cart found with ID: #{@cart.id}"
      end
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[
                                        first_name last_name phone_number
                                        shipping_street shipping_city shipping_state
                                        shipping_postal_code shipping_country
                                        billing_street billing_city billing_state
                                        billing_postal_code billing_country
                                      ])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[
                                        first_name last_name phone_number
                                        shipping_street shipping_city shipping_state
                                        shipping_postal_code shipping_country
                                        billing_street billing_city billing_state
                                        billing_postal_code billing_country
                                      ])
  end

  private

  def set_clothing_types
    @clothing_types = ClothingType.all
  end
end
