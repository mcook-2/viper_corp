# This file should ensure the existence of records required
# to run the application in every environment (production,
# development, test). The code here should be idempotent
# so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command
# (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "csv"

# Clear existing records
Product.destroy_all
Category.destroy_all
Brand.destroy_all
Image.destroy_all

# Load and process the CSV file
CSV.foreach(Rails.root.join("db/y2k_all_products.csv"), headers: true) do |row|
  # Find or create brand
  brand = Brand.find_or_create_by(name: row["brand"])

  # Find or create category
  category = Category.find_or_create_by(name: row["category"])

  # Create product
  product = Product.create!(
    name:           row["name"],
    description:    row["description"],
    features:       row["features"],
    stock_quantity: rand(10..350),
    category:,
    brand:
  )

  # Create product prices
  ProductPrice.create!(
    product:,
    start_date: Time.zone.now,
    end_date:   nil,
    price:      row["price"]
  )

  # Create images
  images = row["images"].split("|")
  images.each do |image_url|
    Image.create!(
      product:,
      url:     image_url
    )
  end
end
