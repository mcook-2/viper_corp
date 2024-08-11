class TaxRate < ApplicationRecord
  has_many :product_sales

  validates :province, :gst_rate, :pst_rate, :hst_rate, presence: true
  validates :gst_rate, :pst_rate, :hst_rate, numericality: { greater_than_or_equal_to: 0 }

  def total_tax_rate
    gst_rate + pst_rate + hst_rate
  end
end
