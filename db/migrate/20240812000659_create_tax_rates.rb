class CreateTaxRates < ActiveRecord::Migration[7.1]
  def change
    create_table :tax_rates do |t|
      t.string :province, null: false
      t.decimal :gst_rate, null: false, default: 0
      t.decimal :hst_rate, null: false, default: 0
      t.decimal :pst_rate, null: false, default: 0
      t.datetime :effective_date, null: false

      t.timestamps
    end

    add_index :tax_rates, :province
  end
end