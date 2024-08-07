require "csv"

def fix_csv(input_file, output_file)
  fixed_rows = []

  CSV.foreach(input_file, headers: true, quote_char: '"', col_sep: ",") do |row|
    # Join description and features fields into single lines
    row["description"] = row["description"].gsub("\n", " ").strip
    row["features"] = row["features"].gsub("\n", " ").strip

    fixed_rows << row
  end

  # Write the fixed rows to a new CSV file
  CSV.open(output_file, "w", write_headers: true, headers: fixed_rows.first.headers,
quote_char: '"', col_sep: ",") do |csv|
    fixed_rows.each do |row|
      csv << row
    end
  end
end

input_file = "all_products.csv"
output_file = "output.csv"

fix_csv(input_file, output_file)
