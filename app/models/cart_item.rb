class CartItem < ApplicationRecord
  # Associations
  belongs_to :cart
  belongs_to :product

  # Validations
  validates :quantity, numericality: { greater_than: 0}

  def total
    current_price = product.product_prices.where(
      "start_date <= ? AND (end_date IS NULL OR end_date >= ?)", Time.zone.today, Time.zone.today).first&.price # rubocop:disable Layout/LineLength
    if current_price
      current_price * quantity
    else
      123 # Handle case where there is no valid price
    end
  end
end
