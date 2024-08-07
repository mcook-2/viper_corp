require "httparty"
require "nokogiri"
require "csv"
require "uri"

# Define the data structures to store the scraped data
Product = Struct.new(:url, :name, :price, :brand, :category, :description, :features, :images)

# Method to fetch a page's content
def fetch_page(url)
  response = HTTParty.get(url, headers: { "User-Agent" => "Mozilla/5.0" })
  response.success? ? response.body : ""
rescue StandardError => e
  Rails.logger.debug "Error fetching #{url}: #{e.message}"
  ""
end

# Method to scrape a product page
def scrape_product_page(product_url)
  document = Nokogiri::HTML(fetch_page(product_url))

  {
    name:        extract_product_name(document),
    price:       clean_price(extract_product_price(document)),
    brand:       "y2k",
    description: extract_full_description(document),
    features:    extract_features(document),
    images:      extract_image_urls(document)
  }
end

# Methods to extract product page data
def extract_product_name(document)
  document.at_css(".product-title")&.text&.strip || "No Name"
end

def extract_product_price(document)
  document.at_css(".price-list .price")&.text&.strip || "No Price"
end

def clean_price(price)
  price&.gsub(/[^0-9.]/, "")
end

def extract_image_urls(document)
  document.css(".product__media-image-wrapper img").map { |img| img["src"] }
end

def extract_full_description(document)
  heading = document.at_css(".product-tabs__tab-item-content.rte h2")&.text&.strip || ""
  paragraph = document.at_css(".product-tabs__tab-item-content.rte p")&.text&.strip || ""
  "#{heading}\n#{paragraph}".strip
end

def extract_features(document)
  document.css(".product-tabs__tab-item-content.rte ul li").map(&:text).join(", ")
end

# Method to scrape a collection page
def scrape_collection_page(url, category, products)
  pages_to_scrape = [url]
  pages_discovered = [url]

  until pages_to_scrape.empty?
    page_to_scrape = pages_to_scrape.pop
    document = Nokogiri::HTML(fetch_page(page_to_scrape))

    Rails.logger.debug "\nProcessing URL: #{page_to_scrape}"

    process_products(document, url, category, products)
    handle_pagination(document, pages_to_scrape, pages_discovered)

    sleep(rand(1..3)) # Rate limiting to avoid hitting server too fast
  end
end

# Method to grab all data from collections page & product page
def process_products(document, url, category, products)
  product_items = document.css(".product-item")
  product_items.each_with_index do |product, index|
    product_data = extract_product_data(product, url)
    additional_details = scrape_product_page(product_data[:url])

    products << build_product(product_data, additional_details, category)

    log_progress(index + 1, product_items.size)
  end

  Rails.logger.debug # To move to the next line after finishing
end

# Build a Product object from the provided data
def build_product(product_data, additional_details, category)
  Product.new(
    product_data[:url],
    product_data[:name],
    additional_details[:price],
    additional_details[:brand],
    category,
    additional_details[:description],
    additional_details[:features],
    additional_details[:images]
  )
end

# Log the progress of product processing
def log_progress(current, total)
  Rails.logger.debug "\rProcessing product #{current}/#{total}"
end

# method to extract collections page level data
def extract_product_data(product, url)
  {
    name: product.at_css(".product-item-meta__title")&.text&.strip || "No Name",
    url:  URI.join(url, product.at_css("a")&.[]("href")).to_s
  }
end

def handle_pagination(document, pages_to_scrape, pages_discovered)
  document.css("a.next-page").each do |a|
    new_page = URI.join(url, a.attribute("href").value).to_s
    if !pages_discovered.include?(new_page) && !pages_to_scrape.include?(new_page)
      pages_to_scrape.push(new_page)
      pages_discovered.push(new_page)
    end
  end
end

# Method to create a CSV file
def create_csv(filename, products)
  CSV.open(filename, "wb", write_headers: true,
                           headers:       csv_headers) do |csv|
    products.each do |product|
      csv << product_to_row(product)
    end
  end

  Rails.logger.debug "\nCollection page scraping completed.
  Check the '#{filename}' file for results."
end

def csv_headers
  ["url", "name", "price", "brand", "category", "description", "features", "images"]
end

def product_to_row(product)
  [
    product.url, product.name, product.price, product.brand, product.category,
    product.description, product.features, product.images.join("|")
  ]
end

def extract_category(url)
  # Extract the last segment of the path after '/y2k-'
  category_with_prefix = URI.parse(url).path.split("/").last
  # Remove the 'y2k-' prefix
  category = category_with_prefix.sub(/^y2k-/, "")
  # Clean up any leading or trailing slashes
  category.strip!
  category
end

# List of URLs
urls = [
  "https://y2k-wave.com/collections/y2k-hoodie",
  "https://y2k-wave.com/collections/y2k-shirts",
  "https://y2k-wave.com/collections/y2k-jeans",
  "https://y2k-wave.com/collections/y2k-pants",
  "https://y2k-wave.com/collections/y2k-shoes",
  "https://y2k-wave.com/collections/y2k-sunglasses",
  "https://y2k-wave.com/collections/y2k-tops",
  "https://y2k-wave.com/collections/y2k-dress",
  "https://y2k-wave.com/collections/y2k-jacket",
  "https://y2k-wave.com/collections/y2k-beanie",
  "https://y2k-wave.com/collections/y2k-belt",
  "https://y2k-wave.com/collections/y2k-hat",
  "https://y2k-wave.com/collections/y2k-sweater",
  "https://y2k-wave.com/collections/y2k-jewelry",
  "https://y2k-wave.com/collections/y2k-skirt"
]

# List to store all products
all_products = []

urls.each do |url|
  category = extract_category(url)
  scrape_collection_page(url, category, all_products)
end

# Create CSV file with all products
create_csv("all_products.csv", all_products)
