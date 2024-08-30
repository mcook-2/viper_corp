class Review < ApplicationRecord
  # Associations
  belongs_to :product
  belongs_to :user

  # Validations
end
