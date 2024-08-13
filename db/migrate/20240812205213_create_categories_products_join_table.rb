class CreateCategoriesProductsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_table :categories_products, id: false do |t|
      t.bigint :category_id, null: false
      t.bigint :product_id, null: false

      t.index [:category_id, :product_id], unique: true
      t.index :product_id
    end

    add_foreign_key :categories_products, :categories
    add_foreign_key :categories_products, :products
  end
end
