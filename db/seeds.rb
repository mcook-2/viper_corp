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
ClothingType.destroy_all
Category.destroy_all
Brand.destroy_all
Image.destroy_all
TaxRate.destroy_all

# Load and process the CSV file
CSV.foreach(Rails.root.join("db/y2k_all_products.csv"), headers: true) do |row|
  # Find or create brand
  brand = Brand.find_or_create_by(name: row["brand"])

  # Find or create clothing type
  clothing_type = ClothingType.find_or_create_by(name: row["category"])

  # Create product
  product = Product.create!(
    name:          row["name"],
    description:   row["description"],
    features:      row["features"],
    clothing_type:,
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

tax_rates = [
  { province: "Alberta", gst_rate: 0.05, hst_rate: 0.00, pst_rate: 0.00,
effective_date: Time.zone.today },
  { province: "British Columbia", gst_rate: 0.05, hst_rate: 0.00, pst_rate: 0.07,
effective_date: Time.zone.today },
  { province: "Manitoba", gst_rate: 0.05, hst_rate: 0.00, pst_rate: 0.07,
effective_date: Time.zone.today },
  { province: "New Brunswick", gst_rate: 0.15, hst_rate: 0.00, pst_rate: 0.00,
effective_date: Time.zone.today },
  { province: "Newfoundland and Labrador", gst_rate: 0.15, hst_rate: 0.00, pst_rate: 0.00,
effective_date: Time.zone.today },
  { province: "Northwest Territories", gst_rate: 0.05, hst_rate: 0.00, pst_rate: 0.00,
effective_date: Time.zone.today },
  { province: "Nova Scotia", gst_rate: 0.15, hst_rate: 0.00, pst_rate: 0.00,
effective_date: Time.zone.today },
  { province: "Nunavut", gst_rate: 0.05, hst_rate: 0.00, pst_rate: 0.00,
effective_date: Time.zone.today },
  { province: "Ontario", gst_rate: 0.13, hst_rate: 0.00, pst_rate: 0.00,
effective_date: Time.zone.today },
  { province: "Quebec", gst_rate: 0.05, hst_rate: 0.00, pst_rate: 0.09975,
effective_date: Time.zone.today },
  { province: "Prince Edward Island", gst_rate: 0.15, hst_rate: 0.00, pst_rate: 0.00,
effective_date: Time.zone.today },
  { province: "Saskatchewan", gst_rate: 0.05, hst_rate: 0.00, pst_rate: 0.06,
effective_date: Time.zone.today },
  { province: "Yukon", gst_rate: 0.05, hst_rate: 0.00, pst_rate: 0.00,
effective_date: Time.zone.today }
]

tax_rates.each do |rate|
  TaxRate.create!(rate)
end

categories = [
  "Graphic", "Vintage", "Y2K", "Floral", "Zip-Up", "Cropped", "Skeleton",
  "Rhinestone", "Star", "Oversized", "Japanese", "Star", "Aesthetic", "Spider",
  "Heart", "Band", "Logo", "Casual", "Baggy", "Ripped", "Printed", "Cargo",
  "Flare", "High-Waisted", "Denim", "Goth", "Patchwork", "Jogger", "Sweatpants",
  "Parachute", "Track", "Baggy Cargo", "Functional", "Designer", "Chunky",
  "Platform", "Canvas", "High-Top", "Chunky Sole", "Sporty", "Fashion"
]

categories.each do |category_name|
  Category.find_or_create_by!(name: category_name)
end

if Rails.env.development?
  AdminUser.create!(email: "admin@example.com", password: "password",
                    password_confirmation: "password")

  User.create(
    email:                 "john@doe.com",
    password:              "password",
    password_confirmation: "password",
    first_name:            "John",
    last_name:             "Doe",
    phone_number:          "123-456-7890",
    shipping_street:       "123 Main St",
    shipping_city:         "Winnipeg",
    shipping_state:        "MB",
    shipping_postal_code:  "R3C 1A2",
    shipping_country:      "Canada",
    billing_street:        "456 Elm St",
    billing_city:          "Winnipeg",
    billing_state:         "MB",
    billing_postal_code:   "R3C 2B4",
    billing_country:       "Canada"
  )

end
