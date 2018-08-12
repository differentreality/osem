class CreateSponsorSwags < ActiveRecord::Migration[5.0]
  def change
    create_table :sponsor_swags do |t|
      t.references :sponsor
      t.string :name
      t.integer :quantity
      t.text :notes

      t.timestamps
    end
  end
end
