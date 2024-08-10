class AdminController < ApplicationController
  def index
  end

  def products
    @products = Product.all
  end

  def show_product
    @product = Product.find(params[:id])
  end
  def orders
  end

  def users
  end

  def show_about_page
  end
end
