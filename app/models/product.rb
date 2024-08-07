class Product < ApplicationRecord
  # Associations
  belongs_to :category
  belongs_to :brand
  has_many :orders, through: :order_items
  has_many :order_items, dependent: :destroy
  has_many :product_prices, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :reviews, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :description, presence: true
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
