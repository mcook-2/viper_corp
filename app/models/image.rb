class Image < ApplicationRecord
  # Associations
  belongs_to :product

  # Validations
  validates :url, presence: true
end
