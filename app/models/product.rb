class Product < ApplicationRecord
  # Associations
  belongs_to :clothing_type
  has_and_belongs_to_many :categories
  belongs_to :brand
  has_many :orders, through: :order_items
  has_many :order_items, dependent: :destroy
  has_many :product_sales, dependent: :destroy
  has_many :product_prices, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :cart_items, dependent: :nullify
  has_many :carts, through: :cart_items

  # Nested attributes
  accepts_nested_attributes_for :images, allow_destroy: true
  accepts_nested_attributes_for :product_prices, allow_destroy: true
  accepts_nested_attributes_for :categories, allow_destroy: true
  accepts_nested_attributes_for :brand, allow_destroy: true

  # Validations
  validates :name, presence: true
  validates :description, presence: true
end
