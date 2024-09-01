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

    total_price = effective_price
    self.gst_total = calculate_gst(total_price)
    self.hst_total = calculate_hst(total_price)
    self.pst_total = calculate_pst(total_price)
    self.tax_total = calculate_tax_total
    self.tax_included_total = total_price + tax_total
  end

  private

  def calculate_gst(total_price)
    total_price * tax_rate.gst_rate
  end

  def calculate_hst(total_price)
    total_price * tax_rate.hst_rate
  end

  def calculate_pst(total_price)
    total_price * tax_rate.pst_rate
  end

  def calculate_tax_total
    gst_total + hst_total + pst_total
  end

  # Callback to calculate tax totals before saving the record
  before_save :calculate_tax_totals
end
