class CreateInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :invoices do |t|
      t.integer :no
      t.datetime :date
      t.references :user, foreign_key: true
      t.references :conference, foreign_key: true
      t.text :description
      t.integer :quantity
      t.integer :total_quantity
      t.float :item_price
      t.float :total_price
      t.float :total_amount
      t.float :vat
      t.float :payable
      t.text :payable_text
      t.text :quantity_text
      t.boolean :paid

      t.timestamps
    end
  end
end
