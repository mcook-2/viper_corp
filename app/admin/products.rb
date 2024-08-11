ActiveAdmin.register Product do


  show do

    # show link to the product page on the store
    panel 'Product Page' do
      link_to 'View Product Page', product_url(product), target: '_blank'
    end

    attributes_table do
      row :name
      row :description
      row :features
      row :stock_quantity
      row :category
      row :brand
      row :created_at
      row :updated_at
    end

    # show for images
    panel 'Images' do
      if product.images.any?
        table_for product.images do
          column 'Image' do |image|
            image_tag(image.url, size: '100x100')
          end
        end
      else
        para 'No images available.'
      end
    end

    # show for reviews
    panel 'Reviews' do
      if product.reviews.any?
        table_for product.reviews.order(created_at: :desc) do
          column 'Customer' do |review|
            review.customer.email
          end
          column 'Rating' do |review|
            review.rating
          end
          column 'Comment' do |review|
            review.comment
          end
          column 'Timestamp' do |review|
            review.timestamp.strftime('%B %d, %Y %H:%M')
          end
        end
      else
        para 'No reviews yet.'
      end
    end

    # show for product prices
    panel 'Prices' do
      if product.product_prices.any?
        table_for product.product_prices.order(start_date: :desc) do
          column 'Price' do |price|
            number_to_currency(price.price)
          end
          column 'Start Date' do |price|
            price.start_date.strftime('%B %d, %Y')
          end
          column 'End Date' do |price|
            price.end_date ? price.end_date.strftime('%B %d, %Y') : 'N/A'
          end
        end
      else
        para 'No prices available.'
      end
    end

    # show for product colors
    panel 'Colors' do
      if product.product_colors.any?
        table_for product.product_colors do
          column 'Product Colors' do |product_color|
            color = product_color.color
            content_tag(:div, style: "display: flex; align-items: center;") do
              concat content_tag(:div, '', style: "background-color: #{color.hex_code}; width: 20px; height: 20px; border: 1px solid #000; margin-right: 10px; display: inline-block;")
              concat content_tag(:span, "#{color.name}", style: "font-weight: bold; margin-right: 10px;")  # Added margin-right for spacing
              concat content_tag(:span, "( #{color.hex_code})", style: "font-weight: normal;")
            end
          end
        end
      else
        para 'No colors available.'
      end
    end

    # ActiveAdmin comments section
    active_admin_comments
  end

end
