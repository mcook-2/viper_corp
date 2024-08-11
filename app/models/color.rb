class Color < ApplicationRecord
  # Associations
  has_many :product_colors
  has_many :products, through: :product_colors

  validates :name, presence: true
  validates :hex_code, presence: true,
                       format:   { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color code" } # rubocop:disable Layout/LineLength
end