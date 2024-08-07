class ProductsController < ApplicationController
  def index
    @products = Product.all
    @products = filter_by_category(@products)
    @products = filter_by_sale(@products)
    @products = filter_by_new(@products)
    @products = sort_by_recently_updated(@products)
    @products = paginate(@products)
  end

  def show
    @product = Product.find(params[:id])
  end

  private

  def filter_by_category(products)
    return products if params[:category_id].blank?

    products.where(category_id: params[:category_id])
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

  def paginate(products)
    products.page(params[:page]).per(10)
  end
end
