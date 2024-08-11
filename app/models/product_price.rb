class ProductPrice < ApplicationRecord
  # Associations
  belongs_to :product

  # Validations
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
