class PaymentMethod < ApplicationRecord
  # Associations
  belongs_to :customer

  # Validations
  validates :card_number, presence: true
  validates :experation_date, presence: true
  validates :cvv, presence: true
end
