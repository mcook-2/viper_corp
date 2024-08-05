class CreateProductPrices < ActiveRecord::Migration[7.1]
  def change
    create_table :product_prices do |t|
      t.references :product, null: false, foreign_key: true
      t.datetime :start_date
      t.datetime :end_date
      t.decimal :price

      t.timestamps
    end
  end
end
