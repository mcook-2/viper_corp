class Category < ApplicationRecord
  has_and_belongs_to_many :products
  has_and_belongs_to_many :clothing_types
end
