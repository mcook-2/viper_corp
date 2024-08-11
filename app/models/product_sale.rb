class ProductSale < ApplicationRecord
  # Associations
  belongs_to :product
  belongs_to :tax_rate

  # Validations
  validates :original_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sale_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :discount_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 } # rubocop:disable Layout/LineLength
  validates :before_tax_total, :gst_total, :hst_total, :pst_total, :tax_total, :tax_included_total,
            presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_rate, presence: true

  # Methods

  # Returns the current price for the product sale
  def effective_price
    sale_price || original_price
  end

  def calculate_tax_totals
    return if sale_price.blank?

    # this logic might not work??
    total_price = effective_price
    self.gst_total = total_price * tax_rate.gst_rate
    self.hst_total = total_price * tax_rate.hst_rate
    self.pst_total = total_price * tax_rate.pst_rate
    self.tax_total = gst_total + hst_total + pst_total
    self.tax_included_total = total_price + tax_total
  end

  # Callback to calculate tax totals before saving the record
  before_save :calculate_tax_totals
end
