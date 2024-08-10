class Color < ApplicationRecord
  # Associations
  has_many :product_colors, dependent: :nullify
  has_many :products, through: :product_colors

  # Validations
  validates :name, presence: true
end
