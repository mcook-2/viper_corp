class Review < ApplicationRecord
  # Associations
  belongs_to :product
  belongs_to :customer

  # Validations
end
