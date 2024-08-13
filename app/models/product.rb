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
  has_many :reviews, dependent: :destroy
  has_many :product_colors, dependent: :destroy
  has_many :colors, through: :product_colors

  # Nested attributes
  accepts_nested_attributes_for :images, allow_destroy: true
  accepts_nested_attributes_for :product_prices, allow_destroy: true
  accepts_nested_attributes_for :product_colors, allow_destroy: true
  accepts_nested_attributes_for :categories, allow_destroy: true
  accepts_nested_attributes_for :brand, allow_destroy: true

  # Validations
  validates :name, presence: true
  validates :description, presence: true
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_create :set_default_color

  private

  def set_default_color
    return unless colors.empty?

    white_color = Color.find_or_create_by(name: "White", hex_code: "#FFFFFF")
    colors << white_color
  end
end
