class ApplicationController < ActionController::Base
  before_action :set_clothing_types

  private

  def set_clothing_types
    @clothing_types = ClothingType.all
  end
end
