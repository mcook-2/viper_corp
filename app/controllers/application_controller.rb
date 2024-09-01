class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :set_clothing_types

  before_action :set_render_cart
  before_action :initialize_cart

  def set_render_cart
    @render_cart = true
  end

  def initialize_cart # rubocop:disable Metrics/AbcSize
    if user_signed_in?
      @cart = Cart.find_by(id: session[:cart_id], user_id: current_user.id)

      if @cart.nil?
        @cart = Cart.create(user: current_user)
        session[:cart_id] = @cart.id if @cart.persisted?
      end
    else
      @cart = Cart.find_by(id: session[:cart_id])

      if @cart.nil?
        @cart = Cart.create
        @cart.persisted?
        session[:cart_id] = @cart.id

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
