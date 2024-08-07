require "httparty"
require "nokogiri"
require "csv"
require "set"
require "concurrent-ruby"
require "uri"

# Define the data structure to store the scraped data
Product = Struct.new(:url, :image, :name, :price, :brand, :additional_images)

def fetch_page(url)
  response = HTTParty.get(url, headers: { "User-Agent" => "Mozilla/5.0" })
  if response.success?
    response.body
  else
    # Log the HTTP status code and response body on failure
    Rails.logger.debug "Failed to fetch #{url}. HTTP Status: #{response.code}"
    Rails.logger.debug "Response Body: #{response.body[0..500]}" # Output only the first 500 characters of the response body
    ""
  end
rescue HTTParty::Error => e
  # Catch and log any HTTParty-specific errors
  Rails.logger.debug "HTTParty Error while fetching #{url}: #{e.message}"
  ""
rescue StandardError => e
  # Catch and log any other standard errors
  Rails.logger.debug "Error while fetching #{url}: #{e.message}"
  ""
end

# Method to extract additional images from a product page

def extract_additional_images(product_url)
  response_body = fetch_page(product_url)
  return [] if response_body.empty?

  document = Nokogiri::HTML(response_body)

  # Debug output
  Rails.logger.debug "\rParsing URL: #{product_url}"

  # Select images inside div with class imgTagWrapper
  images = document.css("div.imgTagWrapper img").map { |img| img["src"] }
  images.reject(&:blank?).uniq
end

# Method to extract the search term from the URL
def extract_search_term(url)
  uri = URI.parse(url)
  query_params = URI.decode_www_form(uri.query || "")
  search_term = query_params.to_h["k"]
  search_term.nil? ? "search" : search_term
end

# Method to scrape a search page
def amazon_scrape_search_page(initial_url, max_pages = 2)
  products = []
  pages_to_scrape = [initial_url]
  pages_discovered = [initial_url]
  i = 0

  # Extract search term for filename
  search_term = extract_search_term(initial_url)
  search_term_sanitized = search_term.gsub(/[^0-9a-z]/i, "_") # Sanitize for filename
  products_filename = "products_#{search_term_sanitized}.csv"

  # Thread pool for parallel requests
  Concurrent::FixedThreadPool.new(10)

  while !pages_to_scrape.empty? && i < max_pages
    page_to_scrape = pages_to_scrape.pop
    response_body = fetch_page(page_to_scrape)
    document = Nokogiri::HTML(response_body)

    pagination_links = document.css("ul.a-pagination li.a-last a").map { |a| a.attribute("href") }

    pagination_links.each do |new_pagination_link|
      full_url = "https://www.amazon.ca#{new_pagination_link}"
      unless pages_discovered.include?(full_url) || pages_to_scrape.include?(full_url)
        pages_to_scrape.push(full_url)
        pages_discovered.push(full_url)
      end
    end

    pages_discovered.uniq!

    html_products = document.css("div.s-main-slot div.s-result-item")

    html_products.each do |html_product|
      url = html_product.at_css("h2 a")&.[]("href")
      image = html_product.at_css("img.s-image")&.[]("src")
      name = html_product.at_css("h2 a span")&.text
      brand = html_product.at_css("h2.a-size-mini span.a-size-base-plus")&.text
      price_whole = html_product.at_css("span.a-price-whole")&.text
      price_fraction = html_product.at_css("span.a-price-fraction")&.text
      price = price_whole && price_fraction ? "#{price_whole}.#{price_fraction}" : nil

      next if url.nil? || image.nil? || name.nil? || price.nil? || brand.nil?

      product_url = "https://www.amazon.ca#{url}"
      products << [product_url, image, name, price, brand]
    end

    i += 1
    sleep(rand(1..3)) # Rate limiting to avoid hitting server too fast
  end

  # Write the products to a CSV file
  CSV.open(products_filename, "wb", write_headers: true,
                                    headers:       ["url", "image", "name", "brand", "price"]) do |csv|
    products.each { |product| csv << product }
  end

  Rails.logger.debug "Search page scraping completed. Check the '#{products_filename}' file for results."
end

# Method to add additional images to products from a CSV file
def amazon_add_additional_images(input_filename)
  products = []
  total_rows = CSV.read(input_filename, headers: true).size
  processed_rows = 0

  # Extract search term from filename
  search_term_sanitized = input_filename.match(/products_(.*?)\.csv/)[1]
  search_term_sanitized.gsub("_", " ") # Restore original search term for use in output filename
  output_filename = "products_with_images_#{search_term_sanitized}.csv"

  CSV.foreach(input_filename, headers: true) do |row|
    product_url = row["url"]
    additional_images = extract_additional_images(product_url)
    products << {
      url:               row["url"],
      image:             row["image"],
      name:              row["name"],
      brand:             row["brand"],
      price:             row["price"],
      additional_images: additional_images.join("; ")
    }

    # Calculate and display progress
    processed_rows += 1
    percentage = (processed_rows.to_f / total_rows * 100).to_i
    Rails.logger.debug "\rProcessing: #{percentage}% complete"
  end

  # Write the updated products with additional images to a new CSV file
  CSV.open(output_filename, "wb", write_headers: true,
                                  headers:       ["url", "image", "name", "brand", "price", "additional_images"]) do |csv|
    products.each do |product|
      csv << [product[:url], product[:image], product[:name], product[:brand], product[:price],
              product[:additional_images]]
    end
  end

  Rails.logger.debug "Additional images added. Check the '#{output_filename}' file for results."
end

# Call the functions
search_url = "https://www.amazon.ca/s?k=vaporwave&i=fashion&rh=n%3A21204935011%2Cn%3A21353444011&dc&ds=v1%3AeQ6alIzJHxUDgtgf1fdAMAsIy%2FbCWJiPO3HLwbNJTzs&crid=M26IM176TGRE&qid=1722966701&rnid=21204935011&sprefix=vaporwave%2Cfashion%2C112&ref=sr_nr_n_2"
amazon_scrape_search_page(search_url)
input_filename = "products_#{extract_search_term(search_url).gsub(/[^0-9a-z]/i, '_')}.csv"
amazon_add_additional_images(input_filename)
