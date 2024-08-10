class ApplicationController < ActionController::Base
  before_action :set_categories


  layout "application"

  private

  def set_categories
    @categories = Category.all
  end


end
