class Product < ApplicationRecord
  # Associations
  belongs_to :category
  belongs_to :brand
  has_many :orders, through: :order_items
  has_many :order_items, dependent: :destroy
  has_many :product_sales, dependent: :destroy
  has_many :product_prices, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :product_colors, dependent: :destroy
  has_many :colors, through: :product_colors

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
