class Order < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :order_items, dependent: :nullify
  has_many :products, through: :order_items

  # Validations
  validates :order_date, presence: true
  validates :stauts, presence: true
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
end
