require "uri"

namespace :stripe do # rubocop:disable Metrics/BlockLength
  desc "Create Stripe products and prices for all products in the database"
  task create_products_and_prices: :environment do # rubocop:disable Metrics/BlockLength
    products = Product.includes(:product_prices).all

    if products.empty?
      puts "No products found in the database."
      return
    end

    products.each do |product| # rubocop:disable Metrics/BlockLength
      if product.product_prices.empty?
        puts "No product price found for product with ID #{product.id}. Skipping."
        next
      end

      product_price = product.product_prices.first
      image_urls = product.images.map(&:url).compact.first(8)

      # Fix images URL
      corrected_urls = []
      image_urls.each do |url|
        if url.start_with?("//")
          url = "https:#{url}"
        elsif !url.match?(%r{\Ahttps://})
          puts "Invalid URL detected, correcting: #{url}"
          url = "https://#{url}" unless url.start_with?("http://", "https://")
        end
        corrected_urls << url
      end

      if corrected_urls.empty?
        puts "No valid image URLs found for product with ID #{product.id}. Skipping."
        next
      end

      # Create Stripe Product
      begin
        stripe_product = Stripe::Product.create({
                                                  name:        product.name,
                                                  description: product.description,
                                                  images:      corrected_urls
                                                })

        puts "Created Stripe product with ID #{stripe_product.id} for product #{product.name}"

        # Create Stripe Price
        begin
          price = Stripe::Price.create({
                                         unit_amount: product_price.price.to_i * 100,
                                         currency:    "cad",
                                         product:     stripe_product.id
                                       })

          # Update the product with the newly created Stripe price ID
          product.update!(stripe_price_id: price.id)

          puts "Created Stripe price for product #{product.name} with ID #{price.id}"
        rescue StandardError => e
          puts "Error creating Stripe price for product #{product.name}: #{e.message}"
        end
      rescue StandardError => e
        puts "Error creating Stripe product for product #{product.name}: #{e.message}"
      end
    end

    puts "Stripe product and price creation for all products completed."
  end
end
