require "uri"

namespace :stripe do # rubocop:disable Metrics/BlockLength
  desc "Create a Stripe product and price for a single product"
  task create_product_and_price: :environment do # rubocop:disable Metrics/BlockLength
    test_product_id = "1"
    product = Product.find_by(id: test_product_id)

    if product.nil?
      puts "Product with ID #{test_product_id} not found."
      return
    end

    if product.product_prices.empty?
      puts "No product price found for product with ID #{product.id}."
      return
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
      puts "No valid image URLs found."
      return
    end

    # Create Stripe Product
    begin
      stripe_product = Stripe::Product.create({
                                                name:        product.name,
                                                description: product.description,
                                                images:      corrected_urls
                                              })

      puts "Created Stripe product with ID #{stripe_product.id}"
    rescue StandardError => e
      puts "Error creating Stripe product: #{e.message}"
      return
    end

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
      puts "Error creating Stripe price: #{e.message}"
    end

    puts "Stripe product and price creation for product #{product.name} completed."
  end
end
