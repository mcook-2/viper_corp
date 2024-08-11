class ProductColor < ApplicationRecord
  # Associations
  belongs_to :product
  belongs_to :color

  # Validations
  validates :product_id, presence: true
  validates :color_id, presence: true
end
