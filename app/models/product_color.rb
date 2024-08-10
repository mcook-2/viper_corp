class ProductColor < ApplicationRecord
  # Associations
  belongs_to :product
  belongs_to :color

  # Validations
end
