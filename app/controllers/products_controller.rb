class ProductsController < ApplicationController
  before_action :load_cart

  def index
    @products = Product.all
    @clothing_types = ClothingType.all

    @products = filter_by_clothing_type_id(@products)
    @products = filter_by_new(@products)
    @products = sort_by_recently_updated(@products)
    @products = search_by_keyword(@products)
    @products = paginate(@products)

    return unless params[:clothing_type_id]

    @clothing_type = ClothingType.find_by(id: params[:clothing_type_id])
  end

  def load_cart
    @cart = Cart.find_or_create_by(id: session[:cart_id]) || Cart.create
  end

  def add_to_cart
    product = Product.find(params[:id])
    @cart.add_item(product.id, params[:quantity].to_i)
    redirect_to cart_path, notice: "Product added to cart."
  end

  def show
    @product = Product.find(params[:id])
  end

  def filter_by_clothing_type_id(products)
    return products if params[:clothing_type_id].blank?

    clothing_type = ClothingType.find_by(id: params[:clothing_type_id])
    clothing_type ? products.where(clothing_type_id: clothing_type.id) : products.none
  end

  def filter_by_new(products)
    return products unless params[:new]

    products.where("created_at >= ?", 3.days.ago)
  end

  def sort_by_recently_updated(products)
    return products unless params[:recently_updated]

    products.where("updated_at >= ?", 3.days.ago).order(updated_at: :desc)
  end

  def search_by_keyword(products)
    return products if params[:search].blank?

    products.where("name ILIKE ?", "%#{params[:search]}%")
  end

  def paginate(products)
    products.page(params[:page]).per(10)
  end
end
