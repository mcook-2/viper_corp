class ClothingType < ApplicationRecord
  has_many :products, dependent: :nullify
  has_and_belongs_to_many :categories
end
