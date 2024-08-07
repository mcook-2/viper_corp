require 'httparty'
require 'nokogiri'
require 'csv'
require 'uri'

# Define the data structures to store the scraped data
Product = Struct.new(:url, :name, :price, :brand, :category, :description, :features, :images)

# Method to fetch a page's content
def fetch_page(url)
  begin
    response = HTTParty.get(url, headers: { "User-Agent" => "Mozilla/5.0" })
    response.success? ? response.body : ""
  rescue => e
    puts "Error fetching #{url}: #{e.message}"
    ""
  end
end

# Method to scrape a product page
def scrape_product_page(product_url)
  response_body = fetch_page(product_url)
  document = Nokogiri::HTML(response_body)

  # Extract product details
  product_name = document.at_css('.product-title')&.text&.strip || "No Name"
  product_price = document.at_css('.price-list .price')&.text&.strip || "No Price"

  # Clean up price field to remove non-numeric characters
  product_price.gsub!(/[^0-9.]/, '') if product_price

  # Collect all image URLs
  images = document.css('.product__media-image-wrapper img').map { |img| img['src'] }

  # Extract description details
  description_heading = document.at_css('.product-tabs__tab-item-content.rte h2')&.text&.strip || ""
  description_paragraph = document.at_css('.product-tabs__tab-item-content.rte p')&.text&.strip || ""

  # Combine heading and paragraph into one description
  full_description = "#{description_heading}\n#{description_paragraph}".strip

  # Collect additional features
  features_list = document.css('.product-tabs__tab-item-content.rte ul li').map(&:text).join(', ')

  # Assuming brand is the same for all products in the collection
  brand_name = "y2k"

  {
    name: product_name,
    price: product_price,
    brand: brand_name,
    description: full_description,
    features: features_list,
    images: images
  }
end

# Method to scrape a collection page
def scrape_collection_page(url, category, products)
  pages_to_scrape = [url]
  pages_discovered = [url]
  processed_rows = 0

  while pages_to_scrape.length > 0 do
    page_to_scrape = pages_to_scrape.pop
    response_body = fetch_page(page_to_scrape)
    document = Nokogiri::HTML(response_body)

    puts "\nProcessing URL: #{page_to_scrape}"

    # Extract product information
    document.css('.product-item').each do |product|
      product_name = product.at_css('.product-item-meta__title')&.text&.strip || "No Name"
      product_price = product.at_css('.price-list .price')&.text&.strip || "No Price"

      # Clean up price field to remove extra newlines and spaces, and non-numeric characters
      product_price.gsub!(/\s+/, ' ')
      product_price.gsub!(/[^0-9.]/, '') if product_price

      product_url = URI.join(url, product.at_css('a')&.[]('href')).to_s

      # Fetch additional product details from the product page
      additional_details = scrape_product_page(product_url)

      products << Product.new(product_url, product_name, product_price, additional_details[:brand], category, additional_details[:description], additional_details[:features], additional_details[:images])

      # Update progress
      processed_rows += 1
      print "\rProcessing: #{processed_rows} products processed"
    end

    # Handling pagination (if applicable)
    pagination_links = document.css("a.next-page").map { |a| a.attribute("href") }.compact
    pagination_links.each do |new_pagination_link|
      full_url = URI.join(url, new_pagination_link).to_s
      unless pages_discovered.include?(full_url) || pages_to_scrape.include?(full_url)
        pages_to_scrape.push(full_url)
        pages_discovered.push(full_url)
      end
    end

    sleep(rand(1..3))  # Rate limiting to avoid hitting server too fast
  end
end

def create_csv(filename, products)
  CSV.open(filename, "wb", write_headers: true, headers: ["url", "name", "price", "brand", "category", "description", "features", "images"]) do |csv|
    products.each do |product|
      # Join multiple images with a delimiter
      images_string = product.images.join('|')
      csv << [product.url, product.name, product.price, product.brand, product.category, product.description, product.features, images_string]
    end
  end

  puts "\nCollection page scraping completed. Check the '#{filename}' file for results."
end

def extract_category(url)
  # Extract the last segment of the path after '/y2k-'
  category_with_prefix = URI.parse(url).path.split('/').last
  # Remove the 'y2k-' prefix
  category = category_with_prefix.sub(/^y2k-/, '')
  # Clean up any leading or trailing slashes
  category.strip!
  category
end

# List of URLs
urls = [
  'https://y2k-wave.com/collections/y2k-hoodie',
  'https://y2k-wave.com/collections/y2k-shirts',
  'https://y2k-wave.com/collections/y2k-jeans',
  'https://y2k-wave.com/collections/y2k-pants',
  'https://y2k-wave.com/collections/y2k-shoes',
  'https://y2k-wave.com/collections/y2k-sunglasses',
  'https://y2k-wave.com/collections/y2k-tops',
  'https://y2k-wave.com/collections/y2k-dress',
  'https://y2k-wave.com/collections/y2k-jacket',
  'https://y2k-wave.com/collections/y2k-beanie',
  'https://y2k-wave.com/collections/y2k-belt',
  'https://y2k-wave.com/collections/y2k-hat',
  'https://y2k-wave.com/collections/y2k-sweater',
  'https://y2k-wave.com/collections/y2k-jewelry',
  'https://y2k-wave.com/collections/y2k-skirt'
]

# List to store all products
all_products = []

urls.each do |url|
  category = extract_category(url)
  scrape_collection_page(url, category, all_products)
end

# Create CSV file with all products
create_csv("all_products.csv", all_products)
