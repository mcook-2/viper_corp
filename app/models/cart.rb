class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def add_item(product_id, quantity = 1)
    item = cart_items.find_or_initialize_by(product_id:)
    item.quantity = (item.quantity || 0) + quantity
    item.save
  end

  def update_item(product_id, quantity)
    item = cart_items.find_or_initialize_by(product_id:)
    return unless item

    if quantity.positive?
      item.update(quantity:)
    else
      item.destroy
    end
  end

  def remove_item(product_id)
    cart_items.find_by(product_id:)&.destroy
  end

  def total_items
    cart_items.sum(:quantity)
  end

  def total
    cart_items.to_a.sum(&:total)
  end
end
