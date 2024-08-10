class AdminController < ApplicationController
  layout "admin"

  before_action :set_breadcrumbs,
                only: %i[index products show_product edit_product orders users show_about_page]

  def index
    add_breadcrumb "Dashboard", admin_path
  end

  def products
    @products = Product.all
    @categories = Category.all
    @products = filter_by_category(@products)
    @products = filter_by_sale(@products)
    @products = filter_by_new(@products)
    @products = sort_by_recently_updated(@products)
    @products = search_by_keyword(@products)
    @products = paginate(@products)
    add_breadcrumb "Dashboard", admin_path
    add_breadcrumb "Products", admin_products_path
  end

  def show_product
    @product = Product.find(params[:id])
    add_breadcrumb "Dashboard", admin_path
    add_breadcrumb "Products", admin_products_path
    add_breadcrumb "Product Details"
  end

  def edit_product
    @product = Product.find(params[:id])
    add_breadcrumb "Dashboard", admin_path
    add_breadcrumb "Products", admin_products_path
    add_breadcrumb "Product Details", admin_product_path(@product)
    add_breadcrumb "Edit Product"
  end

  def update_product
    @product = Product.find(params[:id])

    if @product.update(product_params)
      @product.product_prices.create(price: params[:product][:price], start_date: Time.now)
      redirect_to admin_product_path(@product), notice: "Product was successfully updated."
    else
      render :edit_product
    end
  end

  def orders
    add_breadcrumb "Dashboard", admin_path
    add_breadcrumb "Orders", admin_orders_path
  end

  def users
    add_breadcrumb "Dashboard", admin_path
    add_breadcrumb "Users", admin_users_path
  end

  def show_about_page
    add_breadcrumb "Dashboard", admin_path
    add_breadcrumb "About", admin_show_about_page_path
  end

  private

  def set_breadcrumbs
    @breadcrumbs = []
  end

  def add_breadcrumb(name, path = nil)
    @breadcrumbs << { name:, path: }
  end

  def product_params
    params.require(:product).permit(:name, :description, :features, :stock_quantity, :category_id,
                                    :brand_id)
  end

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

  def search_by_keyword(products)
    return products if params[:search].blank?

    products.where("name ILIKE ?", "%#{params[:search]}%")
  end

  def paginate(products)
    products.page(params[:page]).per(50)
  end
end
