class Brand < ApplicationRecord
# Associations
has_many :products

# Validations
validates :name, presence: true
end
