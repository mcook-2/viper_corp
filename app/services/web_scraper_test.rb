require_relative 'web_scraper' # Adjust the path if necessary

# Initialize the scraper with an empty search term (or any other term if you want to customize it)
scraper = WebScraper.new('')

# Call the scrape method and store the results
results = scraper.scrape

# Print the results to the console
results.each do |result|
  puts "Title: #{result[:title]}"
  puts "Price: #{result[:price]}"
  puts "Link: #{result[:link]}"
  puts "------------------------"
end
