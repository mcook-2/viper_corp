class SetDefaultProductColor < ActiveRecord::Migration[7.1]
    def up
      # Find or create the color "White"
      white_color = Color.find_or_create_by(name: 'White', hex_code: '#FFFFFF')

      # Set the color for all existing products if they don't already have one
      Product.find_each do |product|
        product.colors << white_color if product.colors.empty?
      end
    end

    def down
      # handle rollback by removing the "White" color association
      white_color = Color.find_by(name: 'White')
      if white_color
        Product.joins(:colors).where(colors: { id: white_color.id }).each do |product|
          product.colors.delete(white_color)
        end
      end
    end
  end