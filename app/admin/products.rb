ActiveAdmin.register Product do

  permit_params :name, :description, :features, :stock_quantity, :clothing_type_id,
  :brand_id, category_ids: [],
  images_attributes: [:id, :url, :_destroy],
  product_prices_attributes: [:id, :price, :start_date, :end_date, :_destroy],
  product_colors_attributes: [:id, :color_id, :_destroy]


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
      row :clothing_type
      row :categories do
        if product.categories.any?
          ul do
            product.categories.map { |category| li category.name }.join.html_safe
          end
        else
          'No categories associated.'
        end
      end
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

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Product Details' do
      f.input :name
      f.input :description
      f.input :features
      f.input :clothing_type, as: :select, collection: ClothingType.all.map { |c| [c.name, c.id] }, prompt: 'Select Clothing Type'
      f.input :brand_id, as: :select, collection: Brand.all.collect { |b| [b.name, b.id] }, include_blank: 'Select brand'

      # Display current categories applied to the product
      panel 'Current Categories' do
        if f.object.categories.any?
          ul do
            f.object.categories.each do |category|
              li category.name
            end
          end
        else
          para 'No categories applied.'
        end
      end

      # Input field labeled 'Add Categories'
      f.input :category_ids, label: 'Add Categories', as: :select,
              collection: Category.order(:name).collect { |c| [c.name, c.id] },
              include_blank: 'Select categories',
              input_html: { multiple: true }

      # Links to create new brand and category
      f.inputs do
        para do
          concat link_to 'Create New Brand', new_admin_brand_path, class: 'button'
          concat link_to 'Create New Category', new_admin_category_path, class: 'button'
        end
      end
    end

    f.inputs 'Images' do
      # Ensure there are images or initialize a new one
      f.object.images.build if f.object.images.blank?

      f.has_many :images, allow_destroy: true, new_record: true do |img|
        img.input :url, as: :url, label: 'Image URL', placeholder: 'Enter image URL'
      end
    end

    f.inputs 'Prices' do
      f.has_many :product_prices, allow_destroy: true, new_record: true do |price|
        price.input :price
        price.input :start_date, as: :datepicker
        price.input :end_date, as: :datepicker
      end
    end

    f.inputs 'Colors' do
      f.has_many :product_colors, allow_destroy: true, new_record: true do |product_color|
        product_color.input :color, collection: Color.all.map { |c| [c.name, c.id] }, prompt: 'Select a color'
      end
    end

    f.actions
  end


end