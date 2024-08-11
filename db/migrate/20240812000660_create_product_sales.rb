class CreateProductSales < ActiveRecord::Migration[7.1]
  def change
    create_table :product_sales do |t|
      t.references :product_prices, null: false, foreign_key: true
      t.decimal :original_price, null: false
      t.decimal :sale_price, default: nil
      t.decimal :discount_percentage, null: false, default: 0
      t.decimal :before_tax_total, null: false
      t.decimal :gst_total, null: false
      t.decimal :hst_total, null: false
      t.decimal :pst_total, null: false
      t.decimal :tax_total, null: false
      t.decimal :tax_included_total, null: false
      t.references :tax_rate, null: false, foreign_key: true

      t.timestamps
    end
  end
end
