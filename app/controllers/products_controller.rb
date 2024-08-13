class ProductsController < ApplicationController
  def index
    @products = Product.all
    @clothing_types = ClothingType.all # Add this line to fetch clothing types

    @products = filter_by_clothing_types(@products)
    @products = filter_by_sale(@products)
    @products = filter_by_new(@products)
    @products = sort_by_recently_updated(@products)
    @products = search_by_keyword(@products)
    @products = paginate(@products)
  end

  def show
    @product = Product.find(params[:id])
  end

  private

  def filter_by_clothing_types(products)
    return products if params[:clothing_type_id].blank?

    products.where(clothing_type_id: params[:clothing_type_id])
  end

  def filter_by_sale(products)
    return products unless params[:on_sale]

    products.where(on_sale: true)
  end

  def filter_by_new(products)
    return products unless params[:new]

    products.where("created_at >= ?", 1.month.ago)
  end

  def sort_by_recently_updated(products)
    return products unless params[:recently_updated]

    products.order(updated_at: :desc)
  end

  def search_by_keyword(products)
    return products if params[:search].blank?

    products.where("name ILIKE ?", "%#{params[:search]}%")
  end

  def paginate(products)
    products.page(params[:page]).per(10)
  end
end
