class CreateInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :invoices do |t|
      t.integer :no
      t.date :date
      t.references :user, foreign_key: true
      t.references :conference, foreign_key: true
      t.text :description
      t.text :recipient
      t.float :total_amount
      t.float :vat_percent
      t.float :vat
      t.float :payable
      t.boolean :paid
      t.integer :kind

      t.timestamps
    end
  end
end
