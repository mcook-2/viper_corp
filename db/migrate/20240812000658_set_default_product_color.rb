class SetDefaultProductColor < ActiveRecord::Migration[7.1]
  COMMON_COLORS = [
    { name: 'White', hex_code: '#FFFFFF' },
    { name: 'Black', hex_code: '#000000' },
    { name: 'Red', hex_code: '#FF0000' },
    { name: 'Green', hex_code: '#00FF00' },
    { name: 'Blue', hex_code: '#0000FF' },
    { name: 'Yellow', hex_code: '#FFFF00' },
    { name: 'Purple', hex_code: '#800080' },
    { name: 'Orange', hex_code: '#FFA500' },
    { name: 'Pink', hex_code: '#FFC0CB' },
    { name: 'Brown', hex_code: '#A52A2A' },
    { name: 'Gray', hex_code: '#808080' },
    { name: 'Cyan', hex_code: '#00FFFF' },
    { name: 'Magenta', hex_code: '#FF00FF' },
    { name: 'Lime', hex_code: '#00FF00' },
    { name: 'Indigo', hex_code: '#4B0082' },
    { name: 'Violet', hex_code: '#EE82EE' },
    { name: 'Gold', hex_code: '#FFD700' },
    { name: 'Silver', hex_code: '#C0C0C0' },
    { name: 'Maroon', hex_code: '#800000' },
    { name: 'Navy', hex_code: '#000080' }
  ]

  def up
    # Create or find all common colors
    COMMON_COLORS.each do |color_data|
      Color.find_or_create_by(name: color_data[:name], hex_code: color_data[:hex_code])
    end

    # Find the "White" color
    white_color = Color.find_by(name: 'White', hex_code: '#FFFFFF')

    # Set "White" as the default color for all products that don't have any colors
    Product.find_each do |product|
      product.colors = [white_color] if product.colors.empty?
    end
  end

  def down
    # Handle rollback by removing the "White" color association
    white_color = Color.find_by(name: 'White', hex_code: '#FFFFFF')
    if white_color
      Product.joins(:colors).where(colors: { id: white_color.id }).each do |product|
        product.colors.delete(white_color)
      end
    end

    # Optionally, delete all created common colors
    COMMON_COLORS.each do |color_data|
      color = Color.find_by(name: color_data[:name], hex_code: color_data[:hex_code])
      color&.destroy
    end
  end
end
