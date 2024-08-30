class CreatePaymentMethods < ActiveRecord::Migration[7.1]
  def change
    create_table :payment_methods do |t|
      t.references :user, null: false, foreign_key: true
      t.string :card_number
      t.string :expiration_date
      t.string :cvv

      t.timestamps
    end
  end
end
