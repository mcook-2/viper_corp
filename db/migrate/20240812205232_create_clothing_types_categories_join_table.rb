class CreateClothingTypesCategoriesJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_table :clothing_types_categories, id: false do |t|
      t.bigint :clothing_type_id, null: false
      t.bigint :category_id, null: false

      t.index [:clothing_type_id, :category_id], unique: true
      t.index :clothing_type_id
    end

    add_foreign_key :clothing_types_categories, :clothing_types
    add_foreign_key :clothing_types_categories, :categories
  end
end
