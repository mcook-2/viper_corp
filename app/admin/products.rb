ActiveAdmin.register Product do

  permit_params :name, :description, :features, :clothing_type_id,
  :brand_id, category_ids: [],
  images_attributes: [:id, :url, :_destroy],
  product_prices_attributes: [:id, :price, :start_date, :end_date, :_destroy]


  show do

    # show link to the product page on the store
    panel 'Product Page' do
      link_to 'View Product Page', product_url(product), target: '_blank'
    end

    attributes_table do
      row :name
      row :description
      row :features
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

    # ActiveAdmin comments section
    active_admin_comments
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.object.errors.full_messages.each do |message|
      li message
    end

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

    f.actions
  end


end