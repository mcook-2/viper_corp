class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|

      t.string :first_name
      t.string :last_name
      t.string :phone_number

      t.string :shipping_street
      t.string :shipping_city
      t.string :shipping_state
      t.string :shipping_postal_code
      t.string :shipping_country

      t.string :billing_street
      t.string :billing_city
      t.string :billing_state
      t.string :billing_postal_code
      t.string :billing_country

      t.timestamps
    end
  end
end
