# app/models/session_cart.rb

class SessionCart
  attr_reader :items

  def initialize(session)
    @session = session
    @items = @session[:cart] ||= []
  end

  def add_item(product_id, quantity = 1)
    item = find_item(product_id)
    if item
      item["quantity"] += quantity
    else
      @items << { "product_id" => product_id, "quantity" => quantity }
    end
    save
  end

  def update_item(product_id, quantity)
    item = find_item(product_id)
    if item
      if quantity.positive?
        item["quantity"] = quantity
      else
        remove_item(product_id)
      end
    end
    save
  end

  def remove_item(product_id)
    @items.reject! { |i| i["product_id"] == product_id }
    save
  end

  def total_items
    @items.sum { |item| item["quantity"] }
  end

  def clear
    @items.clear
    save
  end

  private

  def find_item(product_id)
    @items.find { |i| i["product_id"] == product_id }
  end

  def save
    @session[:cart] = @items
  end
end
