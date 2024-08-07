class Product < ApplicationRecord
  # Associations
  belongs_to :category
  belongs_to :brand
  has_many :order_items
  has_many :orders, through: :order_items
  has_many :product_prices
  has_many :images
  has_many :reviews

  # Validations
  validates :name, presence: true
  validates :description, presence: true
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
